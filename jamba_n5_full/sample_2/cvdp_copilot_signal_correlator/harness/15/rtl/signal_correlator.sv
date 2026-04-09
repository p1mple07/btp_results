module signal_correlator(
    input clk,
    input reset,
    input [7:0] input_signal,
    input [7:0] reference_signal,
    output reg [3:0] correlation_output
);

    wire [3:0] sum;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            correlation_output <= 0;
            sum <= 0;
        end else begin
            sum <= 0;
            for (integer i = 0; i < 8; i = i + 1) begin
                if (input_signal[i] == reference_signal[i]) begin
                    sum = sum + 2;
                end
            end
            correlation_output <= sum & 15;
        end
    end

endmodule
