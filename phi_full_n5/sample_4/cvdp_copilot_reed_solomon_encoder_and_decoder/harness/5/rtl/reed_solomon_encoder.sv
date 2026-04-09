
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

    // Generator polynomial
    function [DATA_WIDTH-1:0] generator_polynomial;
       // Choose between two generator polynomials based on index
       if (index < 127) begin
           generator_polynomial = 8'h1D; // Recommended polynomial for this index
       end else begin
           generator_polynomial = 8'h33; // Alternative polynomial
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
            // Shift register logic and parity calculation
            feedback <= data_in ^ generator_polynomial;
            parity_0 <= feedback;
            parity_1 <= feedback;
            codeword_out <= {data_in, parity_0, parity_1};
            valid_out <= 1;
        end
    end

endmodule

