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

    function [DATA_WIDTH-1:0] generator_polynomial;
        integer index;
        index = 0;
        return 0x1D ^ (0x33 ^ 0x1D) * index;
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parity_0 <= 0;
            parity_1 <= 0;
            codeword_out <= 0;
            valid_out <= 0;
        else if (enable && valid_in) begin
            feedback <= 0;
            for (int i = 0; i < DATA_WIDTH; i++) begin
                feedback = feedback ^ ((data_in[i] & 1) << (DATA_WIDTH - 1 - i));
                data_in = (data_in >> 1);
            end
            parity_0 <= feedback;
            parity_1 <= (feedback >> DATA_WIDTH);
            codeword_out <= parity_0 | parity_1;
            valid_out <= 1;
        end
    end
endmodule