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
            // Compute parity symbols using the generator polynomial
            feedback <= {feedback[DATA_WIDTH-2:0], data_in};
            parity_1 <= ^(feedback & generator_polynomial);
            parity_0 <= ^(feedback & ~generator_polynomial);
            codeword_out <= {parity_1, parity_0, data_in};
            valid_out <= 1;
        end
    end

    // Define the generator polynomial
    function [DATA_WIDTH-1:0] generator_polynomial;
        // Choose either 8'h1D or 8'h33 based on the index
        case ({K+1, K})
            2'b00: generator_polynomial = 8'h1D;
            2'b01: generator_polynomial = 8'h33;
            2'b10: generator_polynomial = 8'h1D;
            2'b11: generator_polynomial = 8'h33;
            default: generator_polynomial = 8'h00;
        endcase
    endfunction

endmodule