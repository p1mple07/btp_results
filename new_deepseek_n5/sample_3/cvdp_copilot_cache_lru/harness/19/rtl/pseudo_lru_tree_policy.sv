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

    // Sequential logic for reset and recency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i++) begin
                recency[i] <= NBITS_TREE'(0);
            end
        else begin
            if (access) begin
                // Hit: Update recency tree
                recency[index] <= recency_updated;
            end else begin
                // Miss: Compute replacement using Pseudo-LRU
                slot_select_pseudo_lru_tree #(
                    .NWAYS (NWAYS)
                ) slot_select_unit (
                    .array (recency[index]),
                    .index (pseudo_lru_slot)
                );
                // Update recency array to mark replaced way as MRU
                recency[index] <= (recency[index] & ~1) | (1 << pseudo_lru_slot);
            end
        end
    end

    // Implement the code for recency_updated wire
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            recency_updated <= (replicate(NBITS_TREE, 0));
        else begin
            if (access) begin
                recency_updated <= recency[index];
            else begin
                // This should not happen as per behavior constraints
                recency_updated <= (replicate(NBITS_TREE, 0));
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
    logic direction;

    always_comb begin
        // Traverse the tree to find the LRU way
        depth = 0;
        step = 0;
        direction = 0;
        while (depth < MAX_DEPTH) begin
            // Calculate current node index
            integer current_node = (1 << depth) - 1 + step;
            array [current_node] = array[step];
            step = (step + 1) % (1 << (MAX_DEPTH - depth));
            depth = depth + 1;
        end
        index = step - 1;
    end

endmodule