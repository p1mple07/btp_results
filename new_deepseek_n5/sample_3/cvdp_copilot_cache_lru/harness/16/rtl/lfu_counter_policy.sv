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

    integer i, n, min_counter, min_index;

    // Sequential logic for reset and frequency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            // Initialize all counters to zero
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                end
            end
        else begin
            if (access) begin
                // Update frequency counter for hit
                i = index;
                n = way_select;
                if (frequency[i][n] < MAX_FREQUENCY) begin
                    frequency[i][n] <= frequency[i][n] + 1;
                end
            else begin
                // Find least frequently used way
                min_counter = $unsigned($fmax($fmin(frequency[i][0..NWAYS-1])));
                min_index = 0;
                for (i = 1; i < NWAYS; i = i + 1) begin
                    if ($fmin(frequency[i][0..NWAYS-1]) < frequency[min_index][0..NWAYS-1]) begin
                        min_counter = $unsigned($fmin(frequency[i][0..NWAYS-1]));
                        min_index = i;
                    end
                end
                // Replace the least frequently used way
                way_replace = min_index;
                // Reset the counter of the replaced way
                frequency[min_index][0..NWAYS-1] <= COUNTERW'(1);
            end
        end
    end

endmodule