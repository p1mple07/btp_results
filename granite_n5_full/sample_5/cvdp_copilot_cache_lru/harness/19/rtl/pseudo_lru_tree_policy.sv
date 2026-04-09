module pseudo_lru_tree_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input clock,
    input reset,
    input [NINDEXES-1:0] index,
    input [$clog2(NINDEXES)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    localparam int unsigned NBITS_TREE = NWAYS - 1;

    // Recency array to track next way to be replaced
    reg [NBITS_TREE-1:0] recency [NINDEXES-1:0]

    wire [NBITS_TREE-1:0] recency_updated
    wire [$clog2(NINDEXES)-1:0] pseudo_lru_slot

    // Sequential logic for reset and recency updates
    always_ff @(posedge clock or posedge reset

    if (reset) begin
        for (i=0 to NINDEXES-1:0] recency [NINDEXES-1:0].
    end

    // Implement the code for recency_updated wire
    
    // Sequential logic for reset and recency_updated
    always_ff @(posedge clock or posedge reset 
    ) begin
        if (reset) begin
            for (i=0 to NINDEXES-1:0] recency [NINDEXES-1:0].
    end

endmodule