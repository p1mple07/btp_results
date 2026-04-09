module pseudo_lru_tree_policy (#(parameter NWAYS=4, parameter NINDEXES=32));
    localparam int unsigned NBITS_TREE = NWAYS - 1;

    reg [NBITS_TREE-1:0] recency [NINDEXES-1:0];

    wire [NBITS_TREE-1:0] recency_updated;
    wire [$clog2(NWAYS)-1:0] pseudo_lru_slot;

    integer i;

    always_ff @(posedge clock or posedge reset) begin
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

    assign pseudo_lru_slot = slot_select_pseudo_lru_tree(recency[index], way_select);

    assign way_replace = pseudo_lru_slot;

endmodule

module slot_select_pseudo_lru_tree (#(NWAYS)) (
    input [NWAYS-2:0] array,
    output logic [$clog2(NWAYS)-1:0] index
);

    localparam int unsigned MAX_DEPTH = $clog2(NWAYS);

    integer depth;
    logic [$clog2(NWAYS)-1:0] step;
    logic direction;

    always_comb begin
        if (depth == MAX_DEPTH) begin
            index = array[0];
        end else begin
            step = (depth % 2 == 0) ? 0 : 1;
            direction = (step == 0) ? 1 : 0;
            index = (direction == 1) ? (array[array.size() - 1 - (array.size() - 1 - index)]) : array[index];
        end
    end

endmodule
