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

    // Internal registers for shift-register based encoding
    reg [DATA_WIDTH-1:0] feedback;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parity_0 <= 0;
            parity_1 <= 0;
            codeword_out <= 0;
            valid_out <= 0;
        end else if (enable && valid_in) begin
              feedback <= 0;
              for (int i = 0; i < PARITY_SYMBOLS; i++) begin
                  parity_0[i] = feedback ^ data_in[i];
                  feedback <= feedback ^ parity_0[i];
              end
              parity_1 = parity_0[PARITY_SYMBOLS-1];
              assign codeword_out = data_in[0:DATA_WIDTH-1] + [DATA_WIDTH-1-1:DATA_WIDTH-1] * parity_0[0] + parity_1;
              valid_out <= 1;
        end
    end

    function [DATA_WIDTH-1:0] generator_polynomial;
       // Return 8'h1D as per the comment
       return 8'h1D;
    endfunction

endmodule
