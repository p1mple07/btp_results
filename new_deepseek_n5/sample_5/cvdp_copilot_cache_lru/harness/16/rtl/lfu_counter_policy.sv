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
        else begin
            if (access) begin
                // Hit case: Increment frequency for accessed way
                way_select n = way_select;
                if (frequency[index][way_select] < MAX_FREQUENCY) begin
                    frequency[index][way_select] <= frequency[index][way_select] + 1;
                else begin
                    // Decrement counters of other ways that have a counter value higher than 2
                    for (i = 0; i < NWAYS; i = i + 1) begin
                        if (i != way_select && frequency[index][i] > 2) begin
                            frequency[index][i] <= frequency[index][i] - 1;
                        end
                    end
                end
            end else begin
                // Miss case: Replace least frequently used way
                integer min_freq = MAX_FREQUENCY;
                integer min_index = 0;
                
                for (i = 0; i < NWAYS; i = i + 1) begin
                    if (frequency[index][i] < min_freq) begin
                        min_freq = frequency[index][i];
                        min_index = i;
                    end else if (frequency[index][i] == min_freq) begin
                        if (i > min_index) begin
                            min_index = i;
                        end
                    end
                end
                
                // Update the least frequently used way
                frequency[index][min_index] <= 1;
                way_replace = min_index;
            end
        end
    end

endmodule