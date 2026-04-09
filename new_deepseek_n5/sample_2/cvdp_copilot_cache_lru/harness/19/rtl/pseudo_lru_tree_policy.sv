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
        end else begin
            if (access) begin
                recency[index] <= recency_updated;
            end
        end
    end

    // Update recency array logic
    function void update_recurse(int index, int way, int depth) {
        if (depth >= $clog2(NWAYS)) return;
        if (way <= 1) begin
            recency[index] [depth] = 1;
            update_recurse(index, way + 2, depth + 1);
        end else begin
            recency[index] [depth] = 1;
            update_recurse(index, way - 2, depth + 1);
        end
    }

    // Implement the code for recency_updated wire
    always_ff @ (posedge clock) begin
        if (reset) recency_updated <= 0;
        else if (access) begin
            update_recurse(index, way_select, 0);
            recency_updated <= recency[index];
        end else begin
            // Find LRU slot
            pseudo_lru_slot <= slot_select_pseudo_lru_tree#(NWAYS)(recency[index]);
            // Update replaced way to MRU
            update_recurse(index, pseudo_lru_slot, 0);
            recency_updated <= recency[index];
        end
    end

    // Select the Pseudo LRU slot
    slot_select_pseudo_lru_tree#(
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
        depth = 0;
        step = 0;
        direction = 0;
        while (depth < MAX_DEPTH) begin
            if (array[step] == 0) begin
                step = (step == 0) ? 1 : 0;
                direction = 0;
            else
                step = (step == 1) ? 0 : 1;
                direction = 1;
            end
            depth +.1;
        end
        index = step;
    end

endmodule