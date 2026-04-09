
module reed_solomon_encoder #(
    parameter DATA_WIDTH = 8,   // Width of input data symbols
    parameter N = 255,         // Total number of symbols in the codeword
    parameter K = 223          // Number of data symbols
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

    localparam PARITY_SYMBOLS = N - K;// Number of parity symbols 

    // Internal registers for shift-register based encoding
    reg [DATA_WIDTH-1:0] feedback;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers
            parity_0 <= 0 ;
            parity_1 <= 0 ;
            codeword_out <= 0;
            valid_out <= 0;
        end else if (enable && valid_in) begin
            // Compute parity_0 and parity_1 using feedback
            feedback <= generator_polynomial(K) ^ feedback;
            parity_0 <= feedback[DATA_WIDTH-1:DATA_WIDTH-PARITY_SYMBOLS];
            parity_1 <= feedback[DATA_WIDTH-PARITY_SYMBOLS-1:0];

            // Concatenate data and parity symbols to form the codeword
            codeword_out <= {data_in, parity_0, parity_1};
            valid_out <= 1; // Assuming valid output for simplicity
        end
    end

    function [DATA_WIDTH-1:0] generator_polynomial;
        begin
            // Choose the generator polynomial based on the index
            if (K < 256)
                return 8'h1D; // Example polynomial, replace with actual polynomial
            else
                return 8'h33; // Example polynomial, replace with actual polynomial
        endfunction

endmodule

