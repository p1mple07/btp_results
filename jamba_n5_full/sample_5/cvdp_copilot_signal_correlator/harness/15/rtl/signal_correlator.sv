module signal_correlator(
    input clk,
    input reset,
    input [7:0] input_signal,
    input [7:0] reference_signal,
    output reg [3:0] correlation_output
);

    integer i;
    reg [3:0] sum;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            correlation_output = 0;
            sum = 0;
        end else begin
            sum = 0;
            for (i = 0; i < 8; i = i + 1) begin
                if (input_signal[i] == reference_signal[i]) begin
                    sum = sum + 2;
                end
            end
            // Clamp the result to the 4‑bit limit
            if (sum > 15) sum = 15;
        end
    end

endmodule
