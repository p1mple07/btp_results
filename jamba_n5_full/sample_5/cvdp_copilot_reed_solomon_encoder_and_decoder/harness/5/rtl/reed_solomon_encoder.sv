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

    function [DATA_WIDTH-1:0] generator_polynomial;
        return 8'h1D;
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parity_0 <= 0;
            parity_1 <= 0;
            codeword_out <= 0;
            valid_out <= 0;
        end else if (enable && valid_in) begin
            codeword_out = {data_in, parity_0, parity_1};
            valid_out <= 1;
        end
    end

endmodule
