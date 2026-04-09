module lfu_counter_policy (#(parameter NWAYS = 4,
                             parameter NINDEXES = 32,
                             parameter COUNTERW = 2));

    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    reg [(NWAYS * COUNTERW)-1:0] frequency;
    integer i, n;

    // Reset logic
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) + : COUNTERW] <= 0;
                end
            end
        end else begin
            if (access) begin

            end
        end
    end

    // Main logic
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Initialize frequency to zero
            for (i = 0; i < NINDEXES; i = i + 1) {
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][n * COUNTERW + : COUNTERW] <= 0;
                end
            }
        end else begin
            // Check for access
            if (access) begin

            end
        end
    end

    // Handle hit
    always_comb begin
        if (hit) begin
            // Increment the frequency for the accessed way
            frequency[way_select * COUNTERW + : COUNTERW] <= frequency[way_select * COUNTERW + : COUNTERW] + 1;

            // Check if the hit way has reached max frequency
            if (frequency[way_select * COUNTERW + : COUNTERW] == MAX_FREQUENCY) begin
                // Decrement all counters that are above 2
                for (j = 0; j < NWAYS; j++) begin
                    if (frequency[j * COUNTERW + : COUNTERW] > 2) begin
                        frequency[j * COUNTERW + : COUNTERW] <= frequency[j * COUNTERW + : COUNTERW] - 1;
                    end
                end
            end
        end
    end

    // Handle miss
    always_comb begin
        if (!access) begin
            // Find the least frequently used way
            integer best_freq = INF;
            integer best_idx = -1;
            for (i = 0; i < NWAYS; i = i + 1) begin
                for (j = 0; j < NWAYS; j = j + 1) begin
                    if (i == j) continue;
                    if (frequency[i * COUNTERW + : COUNTERW] < frequency[best_freq]) begin
                        best_freq = frequency[i * COUNTERW + : COUNTERW];
                        best_idx = i;
                    end
                    else if (frequency[i * COUNTERW + : COUNTERW] == frequency[best_freq]) begin
                        if (i < best_idx) best_idx = i;
                    end
                end
            end

            // Select the way with lowest index in case of tie
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (i == best_idx) begin
                    way_replace = i;
                    break;
                end
            }

            // Update the frequency for the replaced way to 1
            frequency[best_idx * COUNTERW + : COUNTERW] <= 1;
        end
    end

endmodule
