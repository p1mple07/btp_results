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

    // Correct frequency array declaration: [index][way][counter bits]
    reg [NINDEXES-1:0][NWAYS-1:0][COUNTERW-1:0] frequency;

    integer i, n;

    // Sequential logic for reset and frequency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][n] <= 0;
                end
            end
        end else begin
            if (access) begin
                // Hit case
                if (way_select) begin
                    // Increment the accessed way's counter if not saturated
                    if (frequency[index][way_select] < MAX_FREQUENCY) begin
                        frequency[index][way_select] <= frequency[index][way_select] + 1;
                    else begin
                        // Decrement counters of other ways with higher values
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n != way_select && frequency[index][n] > frequency[index][way_select]) begin
                                frequency[index][n] <= frequency[index][n] - 1;
                            end
                        end
                    end
                end
            end else begin
                // Miss case
                // Find the way with the least frequently used counter
                integer min_counter = MAX_FREQUENCY + 1;
                integer min_index = 0;
                integer replacement_way;

                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (frequency[i][n] < min_counter) begin
                            min_counter = frequency[i][n];
                            min_index = i;
                            replacement_way = n;
                        end else if (frequency[i][n] == min_counter && i < min_index) begin
                            min_index = i;
                            replacement_way = n;
                        end
                    end
                end

                way_replace <= min_index;
            end
        end
    end
endmodule