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

    integer i, depth;

    // Sequential logic for reset and recency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i++) begin
                recency[i] <= NBITS_TREE'(0);
            end
        end else begin
            if (access) begin
                // Update recency tree for hit
                // Traverse from root to leaf (way_select path)
                depth = 0;
                integer pos = 0;
                while (way_select[depth] != 0) begin
                    pos = (1 << depth) - 1 + pos;
                    depth += 1;
                end
                recency[index] <= recency_updated;
            end
        end
    end

    // Implement the code for recency_updated wire

    
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

    always_comb begin
        // Find the Pseudo LRU way index
        direction = 1; // Start from leaf level
        depth = MAX_DEPTH - 1;
        while (depth >= 0) begin
            step = array[(1 << depth) - 1 + (1 << (MAX_DEPTH - depth - 1))];
            if (step == 0) begin
                // Found LRU way at this depth
                index = (1 << depth) - 1 + (1 << (MAX_DEPTH - depth - 1));
                break;
            end else begin
                direction = 0;
                depth -= 1;
            end
        end
    end

endmodule