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
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    if (hit[i]) begin
                        frequency[i][(way_select[i] * COUNTERW) +: COUNTIMERW] <= frequency[i][(way_select[i] * COUNTERW) +: COUNTERW] + 1;
                        if (frequency[i][(way_select[i] * COUNTERW) +: COUNTERW] > MAX_FREQUENCY) begin
                            for (n = 0; n < NWAYS; n = n + 1) begin
                                if ((n!= way_select[i]) && (frequency[i][(n * COUNTERW) +: COUNTIMERW] > 0)) begin
                                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    // Way reselection based on the least frequent way
    always_comb begin
        way_replace = way_select;
        for (n = 0; n < NINDEXES; n = n + 1) begin
            for (i = 0; i < NWAY; i = i + 1) begin
                if ((frequency[n][(i * COUNTERW) +: COUNTIMERW] == 0) || (way_replace[n] == i)) begin
                    continue;
                } else begin
                    way_replace[n] = i;
                    break;
                end
            end
        end
    end

endmodule