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

    function [DATA_WIDTH-1:0] generator_polynomial(integer index);
        if (index < PARITY_SYMBOLS) begin
            return 8'h33; // Example polynomial for simplicity
        end else begin
            return 8'h1D; // Example polynomial for simplicity
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers
            parity_0 <= 0 ;
            parity_1 <= 0 ;
            codeword_out <= 0;
            valid_out <= 0;
        end else if (enable && valid_in) begin
            // Compute parity_0 and parity_1 using the generator_polynomial
            feedback = generator_polynomial(PARITY_SYMBOLS - 1);
            parity_0 = feedback ^ parity_0;
            parity_1 = feedback ^ parity_1;

            // Shift and encode data_in into codeword_out
            codeword_out <= {data_in, parity_0, parity_1};
            valid_out = 1;
        end
    end

endmodule
