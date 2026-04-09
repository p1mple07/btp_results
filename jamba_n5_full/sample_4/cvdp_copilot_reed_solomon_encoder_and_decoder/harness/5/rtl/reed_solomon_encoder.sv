module reed_solomon_encoder #(
    parameter DATA_WIDTH = 8,
    parameter N = 255,
    parameter K = 223
) (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    output reg [DATA_WIDTH-1:0] codeword_out,
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] parity_0,
    output reg [DATA_WIDTH-1:0] parity_1
);

    localparam PARITY_SYMBOLS = N - K;

    reg [DATA_WIDTH-1:0] feedback;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parity_0 <= 0;
            parity_1 <= 0;
            codeword_out <= 0;
            valid_out <= 0;
        end else if (enable && valid_in) begin
            feedback <= 8'h0;
            for (integer i = 0; i < DATA_WIDTH; i = i + 1) begin
                feedback = data_in[i] ^ feedback;
            end
            codeword_out <= data_in << [DATA_WIDTH-1:0];
            codeword_out[DATA_WIDTH + 0:PARITY_SYMBOLS] = feedback[0:PARITY_SYMBOLS-1];
        end
    end

    function [DATA_WIDTH-1:0] generator_polynomial;
        return 8'h1D;
    endfunction

endmodule
