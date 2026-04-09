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

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                end
            end
        else begin
            if (access) begin
                // Hit handling
                integer idx = index * COUNTERW + way_select;
                frequency[idx] <= frequency[idx] + 1;
                if (frequency[idx] > MAX_FREQUENCY) {
                    frequency[idx] <= MAX_FREQUENCY;
                }
                if (frequency[idx] == MAX_FREQUENCY) {
                    // Decrement counters of other ways with counter > 2
                    for (n = 0; n < NWAYS; n = n + 1) {
                        if (n != way_select) {
                            integer freq_idx = index * COUNTERW + n;
                            if (frequency[freq_idx] > 2) {
                                frequency[freq_idx] <= frequency[freq_idx] - 1;
                            }
                        }
                    }
                }
            else begin
                // Miss handling
                integer min_counter = MAX_FREQUENCY;
                integer min_way = 0;
                integer current_min_idx = 0;
                for (n = 0; n < NWAYS; n = n + 1) {
                    integer freq_idx = index * COUNTERW + n;
                    if (frequency[freq_idx] < min_counter) {
                        min_counter = frequency[freq_idx];
                        min_way = n;
                        current_min_idx = n;
                    } else if (frequency[freq_idx] == min_counter) {
                        if (n < min_way) {
                            min_way = n;
                            current_min_idx = n;
                        }
                    }
                }
                way_replace = current_min_idx;
            end
        end
    end
endmodule