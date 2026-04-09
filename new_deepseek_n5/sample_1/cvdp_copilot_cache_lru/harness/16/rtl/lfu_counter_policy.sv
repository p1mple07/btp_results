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
    reg [(NWAYS * COUNTERW)-1:0] frequency[NINDEXES-1:0];

    integer i, n;

    // Sequential logic for reset and frequency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            // Reset all frequency counters to zero
            for (i = 0; i < NINDEXES; i = i + 1) begin
                frequency[i] <= (COUNTERW'(0), COUNTERW'(0), ..., COUNTERW'(0));
            end
        else begin
            if (access) begin
                // Hit case: increment frequency of accessed way
                if (frequency[index] < MAX_FREQUENCY) begin
                    frequency[index] <= frequency[index] + 1;
                end else begin
                    // If already at max frequency, decrement counters of others with higher frequency
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (frequency[index] == frequency[n] && frequency[n] > MAX_FREQUENCY - COUNTERW) begin
                            frequency[n] <= frequency[n] - 1;
                        end
                    end
                end
            end
            // Miss case: replace least frequently used way
            integer min_freq = MAX_FREQUENCY;
            integer min_index = 0;
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (frequency[index][i] < min_freq) begin
                    min_freq = frequency[index][i];
                    min_index = i;
                end else if (frequency[index][i] == min_freq) begin
                    if (i < min_index) begin
                        min_index = i;
                    end
                end
            end
            way_replace <= min_index;
        end
    end

endmodule