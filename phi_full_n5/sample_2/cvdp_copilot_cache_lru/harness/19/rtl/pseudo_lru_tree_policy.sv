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
    localparam int unsigned NBITS_INDEX = $clog2(NIXELSES);

    reg [NBITS_TREE-1:0] recency [NINDEXES-1:0];
    wire [NBITS_TREE-1:0] recency_updated;
    wire [$clog2(NWAYS)-1:0] pseudo_lru_slot;

    integer i;

    // Sequential logic for reset and recency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i++) begin
                recency[i] <= NBITS_TREE'(0);
            end
        end else begin
            if (access) begin
                recency[index] <= recency_updated;
            end
        end
    end

    // Update recency array for hit
    always_comb begin
        if (hit) begin
            // Traverse the tree to mark the selected way as most recently used
            for (int i = NBITS_TREE-1; i >= 0; i = i/2) begin
                int direction = (way_select & (1 << i)) ? -1 : 1;
                int step = (way_select & (1 << (i-1))) ? -1 : 1;
                int index_update = (direction == -1) ? (i + 1) : (i - 1);
                recency[index] = recency[index] + (1 << index_update);
            end
        end
    end

    // Select the Pseudo LRU slot
    slot_select_pseudo_lru_tree #(
        .NWAYS (NWAYS)
    ) slot_select_unit (
        .array (recency[index]),
        .index (pseudo_lru_slot)
    );

    assign way_replace = pseudo_lru_slot;

endmodule : pseudo_lru_tree_policy

module slot_select_pseudo_lru_tree #(
    parameter NWAYS = 4
)(
    input [NWAYS-2:0] array,
    output logic [$clog2(NWAYS)-1:0] index
);

    localparam int unsigned MAX_DEPTH = $clog2(NWAYS);

    integer depth;
    logic [$clog2(NWAYS)-1:0] step;

    always_comb begin
        depth = MAX_DEPTH;
        step = 0;
        index = NWAYS'h0;

        while (depth > 0) begin
            if (array[step]) begin
                index = step;
                step = step + 1'b1;
            end else begin
                step = step - 1'b1;
                depth = depth - 1;
            end
        end
    end

endmodule : slot_select_pseudo_lru_tree
