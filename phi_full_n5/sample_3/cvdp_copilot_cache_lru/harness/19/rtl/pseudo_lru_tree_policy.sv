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

    reg [NBITS_TREE-1:0] recency [NINDEXES-1:0];
    wire [NBITS_TREE-1:0] recency_updated;
    wire [$clog2(NWAYS)-1:0] pseudo_lru_slot;

    integer i;

    // Recency array update logic for hit
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i++) begin
                recency[i] <= NBITS_TREE'(0);
            end
        end else if (access) begin
            // Mark the selected way as most recently used
            recency[index] <= recency[index] ^ way_select;
            recency_updated = recency[index];
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
    logic direction;

    // Pseudo LRU slot selection logic
    always_comb begin
        direction = 1; // Traverse the tree
        index = array;
        depth = MAX_DEPTH;

        // Traverse the tree from the most recently used way
        while (direction && depth > 0) begin
            if (step == 0) begin
                index = index << 1; // Move to left child
                step = MAX_DEPTH - 1;
            end else begin
                index = index >> 1; // Move to right child
                step = step - 1;
            end
            depth = depth - 1;
        end
    end

endmodule : slot_select_pseudo_lru_tree
