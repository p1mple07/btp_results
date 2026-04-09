
module fifo_policy #(
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

    // FIFO array to track next way to be replaced
    reg [$clog2(NWAYS)-1:0] fifo_array [NINDEXES-1:0];

    integer i;

    // Sequential logic for reset and fifo_array updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i++) begin
                fifo_array[i] <= $clog2(NWAYS)'(0);
            end
        end else begin
            if (access && ~hit) begin
                // Only update fifo_array position for misses
                fifo_array[index] <= fifo_array[index] + $clog2(NWAYS)'(1);
            end
        end
    end

    assign way_replace = hit ? fifo_array[index] : $clog2(NWAYS)'(0);

endmodule : fifo_policy
