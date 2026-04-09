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
                frequency[index][(way_select * COUNTERW) +: COUNTERW] <= frequency[index][(way_select * COUNTERW) +: COUNTERW] + 1;
                // Ensure the frequency counter saturates at MAX_FREQUENCY
                if (frequency[index][(way_select * COUNTERW) +: COUNTERW] > MAX_FREQUENCY)
                    frequency[index][(way_select * COUNTERW) +: COUNTERW] = MAX_FREQUENCY;

                // Handle cache hit logic
                if (hit) begin
                    // On a hit, only increment the frequency counter
                end

                // Handle cache miss logic
                else begin
                    // Find the least frequently used way for replacement
                    integer min_counter, min_index;
                    min_counter = MAX_FREQUENCY + 1;
                    for (i = 0; i < NINDEXES; i = i + 1) begin
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (frequency[i][(n * COUNTERW) +: COUNTERW] < min_counter) begin
                                min_counter = frequency[i][(n * COUNTERW) +: COUNTERW];
                                min_index = i;
                            end
                        end
                    end

                    // Replace the least frequently used way
                    for (i = 0; i < NINDEXES; i = i + 1) begin
                        if (i == min_index) begin
                            frequency[i][(way_select * COUNTERW) +: COUNTERW] <= 1;
                        end
                        else begin
                            frequency[i][(way_select * COUNTERW) +: COUNTERW] <= 0;
                        end
                    end
                end
            end
        end
    end

    // Assign the way_replace output based on the least frequently used way
    assign way_replace = way_select; // Placeholder assignment, should be replaced with actual logic

endmodule : lfu_counter_policy
