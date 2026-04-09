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

    reg [(NWAYS * COUNTERW)-1:0] frequency;

    // Always block on clock edge
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NWAYS * COUNTERW; i = i + 1) begin
                frequency[i] <= COUNTERW'(0);
            end
        end else begin

            // Handle access
            if (access) begin
                // Find the way to hit
                if (way_select == index) begin
                    // Increment frequency for this way
                    frequency[way_select * COUNTERW + (way_select + 1)] <= frequency[way_select * COUNTERW + (way_select + 1)] + 1;
                end
            end

            // Miss handling
            else begin
                // Find the least frequent way
                reg best_freq = INFINITY;
                reg best_idx = -1;
                for (i = 0; i < NWAYS * COUNTERW; i = i + 1) begin
                    if (frequency[i] < best_freq) begin
                        best_freq = frequency[i];
                        best_idx = i;
                    end
                end
                way_replace = (best_idx == index) ? (way_select + 1) : best_idx;
                // Reset frequency for the replaced way to zero? Not necessary, but we can leave it.
            end
        end
    end

endmodule
