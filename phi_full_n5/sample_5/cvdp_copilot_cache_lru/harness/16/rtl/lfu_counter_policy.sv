module lfu_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32,
    parameter COUNTERW = 2
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    // Maximum frequency for counters
    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    // Frequency array to track next way to be replaced
    reg [(NWAYS * COUNTERW)-1:0] frequency [NINDEXES-1:0];

    integer i, n;

    // Sequential logic for reset and frequency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                end
            end
        end else begin
            if (access) begin
                // Increment frequency counter for accessed way
                frequency[index][(way_select * COUNTERW) +: COUNTERW] <=
                    frequency[index][(way_select * COUNTERW) +: COUNTERW] + 1;

                // Handle counter overflow
                if (frequency[index][(way_select * COUNTERW) +: COUNTERW] >= MAX_FREQUENCY) begin
                    frequency[index][(way_select * COUNTERW) +: COUNTERW] <= MAX_FREQUENCY;
                end

                // Decrement counters of other ways if hit way is at max frequency
                if (frequency[index][(way_select * COUNTERW) +: COUNTERW] == MAX_FREQUENCY) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n != way_select) begin
                            frequency[index][(n * COUNTERW) +: COUNTERW] <=
                                frequency[index][(n * COUNTERW) +: COUNTERW] - 1;
                        end
                    end
                end
            end
        end
    end

    // Determine least frequently used way for replacement
    always_comb begin
        integer least_used = -1;
        integer n;

        // Find least frequently used way
        for (n = 0; n < NWAYS; n = n + 1) begin
            if (frequency[(index - 1) +: NINDEXES][(n * COUNTERW) +: COUNTERW] <
                frequency[(index - 1) +: NINDEXES][(least_used * COUNTERW) +: COUNTERW]) begin
                least_used = n;
            end
        end

        // Handle tie by selecting the way with lower index
        if (least_used == -1) begin
            least_used = NWAYS - 1;
        end

        // Assign least frequently used way to output
        way_replace = binary_repr(least_used, NWAYS);
    end

endmodule : lfu_counter_policy
