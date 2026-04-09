module pseudo_lru_tree_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    localparam int unsigned NBITS_TREE = NWAYS - 1;

    // Recency array to track next way to be replaced
    reg [NBITS_TREE-1:0] recency [NINDEXES-1:0];

    wire [NBITS_TREE-1:0] recency_updated;
    wire [$clog2(NWAYS)-1:0] pseudo_lru_slot;

    integer i;

    // Reset the recency tree on asynchronous reset
    always_ff @(posedge reset) begin
        for (i = 0; i < NINDEXES; i++) begin
            recency[i] <= 0;
        end
    end

    // Handle cache hits: update the recency path for the selected way
    always_comb @(posedge clock or posedge hit) begin
        if (access) begin
            recency[index] <= recency[index] + 1; // Increment to mark as recently used
        end
    end

    // Compute the MRU slot by traversing the recency tree
    assign recency_updated = recency[index];
    assign pseudo_lru_slot = recency_updated;

    // Select the pseudo‑LRU replacement target
    slot_select_pseudo_lru_tree #(
        .NWAYS (NWAYS)
    ) slot_select_unit (
        .array (recency[index]),
        .index (pseudo_lru_slot)
    );

    assign way_replace = pseudo_lru_slot;

endmodule

module slot_select_pseudo_lru_tree #(
    parameter NWAYS = 4
)(
    input [NWAYS-2:0] array,
    output logic [$clog2(NWAYS)-1:0] index
);

    localparam int unsigned MAX_DEPTH = $clog2(NWAYS);

    integer depth;
    logic [$clog2(NWAYS)-1:0] step;
    logic direction;

    always_comb begin
        for (depth = 0; depth < MAX_DEPTH; depth++) begin
            if (direction == 'left') begin
                step = 0;
            end else begin
                step = 1;
            end
            direction = ~direction;
        end
    end

    assign index = array[$clog2(NWAYS)-1:0];

endmodule
