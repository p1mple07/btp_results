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
                if (!hit) begin
                    // Update frequency counter if not a hit
                    if (frequency[index][way_select * COUNTERW +: COUNTIMERW] < MAX_FREQUENCY) begin
                        frequency[index][way_select * COUNTERW +: COUNTIMERW] <= frequency[index][way_select * COUNTERW +: COUNTIMERW] + COUNTERW'(1);
                    } else begin
                        // Decrement frequencies of other ways if counter reaches maximum
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n!= way_select && frequency[index][n * COUNTERW +: COUNTIMERW] > COUNTIMERW'(1)) begin
                                frequency[index][n * COUNTERW +: COUNTIMERW] <= frequency[index][n * COUNTERW +: COUNTIMERW] - COUNTIMERW'(1);
                            end
                        end
                    end
                end else begin
                    // Reset frequency counter after a hit
                    frequency[index][way_select * COUNTERW +: COUNTIMERW] <= COUNTIMERW'(0);
                end
            end
        end
    end

    // Way replacement logic based on minimum counter value
    wire [COUNTERW-1:0] min_counter;
    reg [COUNTERW-1:0] selected_counter;
    wire [NINDEXES-1:0] min_counters;
    assign min_counters = {min_counter[COUNTERW-2:0], min_counter};
    assign min_counter = {{(NINDEXES - 2) * COUNTERW}{1'b0}}, frequency[0][COUNTERW-1:0]};
    
    generate
        genvar k;
        for (k = 1; k < NINDEXES; k = k + 1) begin
            wire [COUNTERW-1:0] temp_counter;
            assign temp_counter = {{(NINDEXES - k - 1) * COUNTERW}{1'b0}}, frequency[k][COUNTERW-1:0]};
            wire less_than;
            wire equal;
            wire greater_than;
            assign less_than = (temp_counter < min_counter);
            assign equal = (temp_counter == min_counter);
            assign greater_than = (temp_counter > min_counter);
            assign selected_counter = (equal? min_counters[k] : ((less_than || greater_than)? (temp_counter < min_counter? temp_counter : min_counter) : min_counters[k]));
        end
    endgenerate

    assign way_replace = selected_counter[COUNTERW-1:0];

endmodule