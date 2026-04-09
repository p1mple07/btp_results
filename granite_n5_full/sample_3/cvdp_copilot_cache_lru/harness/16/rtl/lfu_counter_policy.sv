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
                    frequency[index][way_select * COUNTERW +: COUNTERW] <= frequency[index][way_select * COUNTERW +: COUNTERW] + COUNTERW'(1);
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if ((n!= way_select) && (frequency[index][n * COUNTERW +: COUNTERW] >= COUNTIMERW'(2))) begin
                            frequency[index][way_select * COUNTERW +: COUNTERW] <= COUNTERW'(0);
                            frequency[index][n * COUNTERW +: COUNTERW] <= COUNTERW'(1);
                            break;
                        end
                    end
                end
            end
        end
    end

    // Way Replacement Logic
    assign way_replace = min_counter();

    function automatic int min_counter;
        int min_val;
        min_val = MAX_FREQUENCY;
        for (int i = 0; i < NINDEXES; i++) begin
            for (int j = 0; j < NWAYS; j++) begin
                if (frequency[i][j * COUNTERW +: COUNTERW] < min_val) begin
                    min_val = frequency[i][j * COUNTERW +: COUNTERW];
                end
            end
        end
        for (int k = 0; k < NINDEXES; k++) begin
            for (int l = 0; l < NWAYS; l++) begin
                if (min_val == frequency[k][l * COUNTERW +: COUNTERW]) begin
                    min_counter = k;
                    break;
                end
            end
        end
    endfunction

endmodule