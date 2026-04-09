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
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                end
            end
        end else begin
            if (access) begin
                // Update frequency counters on cache access
                if (hit) begin
                    // Increment counter for the accessed way
                    if (frequency[index][way_select * COUNTERW +: COUNTERW]!= MAX_FREQUENCY) begin
                        frequency[index][way_select * COUNTERW +: COUNTERW] <= frequency[index][way_select * COUNTERW +: COUNTERW] + 1;
                    }
                end else begin
                    // Decrement counters of other ways if accessed way has reached max frequency
                    if (frequency[index][way_select * COUNTERW +: COUNTERW] == MAX_FREQUENCY) begin
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n!= way_select) begin
                                frequency[index][n * COUNTERW +: COUNTERW] <= 0;
                            end
                        end
                    end

                    // Increment counter for the accessed way
                    frequency[index][way_select * COUNTERW +: COUNTERW] <= 1;
                end
            end

            // Determine the least frequently used way
            integer min_counter = MAX_FREQUENCY;
            integer min_idx = 0;
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (frequency[i][n * COUNTERW +: COUNTERW] < min_counter && frequency[i][n * COUNTERW +: COUNTERW]!= 0) begin
                        min_counter = frequency[i][n * COUNTERW +: COUNTERW];
                        min_idx = i;
                    end
                end
            end

            // Assign the least frequently used way to way_replace
            way_replace <= min_idx;
        end
    end

endmodule