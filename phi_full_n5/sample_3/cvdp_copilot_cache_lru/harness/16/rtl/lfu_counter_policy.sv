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
                // Increment the frequency counter of the accessed way
                if (hit) begin
                    if (frequency[index][(way_select * COUNTERW) +: COUNTERW] < MAX_FREQUENCY) begin
                        frequency[index][(way_select * COUNTERW) +: COUNTERW] <= frequency[index][(way_select * COUNTERW) +: COUNTERW] + 1;
                    end else begin
                        // Decrement the counters of the other ways
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n != way_select) begin
                                frequency[index][(n * COUNTERW) +: COUNTERW] <= frequency[index][(n * COUNTERW) +: COUNTERW] - 1;
                            end
                        end
                    end
                end else begin
                    // Replace the way with the least frequently used counter
                    way_replace <= 0;
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (frequency[index][(n * COUNTERW) +: COUNTERW] < frequency[index][(way_select * COUNTERW) +: COUNTERW]) begin
                            way_replace <= n;
                            break;
                        end
                    end
                    // Set the counter of the replaced way to 1
                    if (way_replace != 0) begin
                        frequency[index][(way_replace * COUNTERW) +: COUNTERW] <= 1;
                    end
                end
            end
        end
    end

endmodule : lfu_counter_policy
