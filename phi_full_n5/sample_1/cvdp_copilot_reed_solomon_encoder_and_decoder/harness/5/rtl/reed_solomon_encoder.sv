
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
    reg [DATA_WIDTH-1:0] parity_register [PARITY_SYMBOLS-1:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers
            parity_0 <= 0 ;
            parity_1 <= 0 ;
            codeword_out <= 0;
            valid_out <= 0;
            feedback <= 0;
        end else if (enable && valid_in) begin
            // Compute parity_0 and parity_1 using generator_polynomial
            generator_polynomial = generator_polynomial();
            parity_0 <= feedback ^ parity_register[0];
            parity_1 <= feedback ^ parity_register[PARITY_SYMBOLS-1];
            feedback <= parity_0 ^ parity_1;
            codeword_out <= data_in << PARITY_SYMBOLS | parity_0 << 0 | parity_1 << (DATA_WIDTH-1);
            valid_out <= (data_in != 0) && (parity_0 != 0) && (parity_1 != 0);
        end
    end

    function [DATA_WIDTH-1:0] generator_polynomial;
        // Choose between 8'h1D (degree 1) and 8'h33 (degree 32) based on some condition
        // Here we assume a simple condition based on the index for demonstration purposes
        // Replace this with the actual condition for your application
        if (index < 128) begin
            return 8'h1D;
        end else begin
            return 8'h33;
        end
    endfunction

endmodule

