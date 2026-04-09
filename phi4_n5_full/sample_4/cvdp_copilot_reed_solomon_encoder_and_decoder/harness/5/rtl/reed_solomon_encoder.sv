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

    localparam PARITY_SYMBOLS = N - K; // Number of parity symbols 

    // Internal register used for shift-register based encoding
    reg [DATA_WIDTH-1:0] feedback;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers
            parity_0    <= 0;
            parity_1    <= 0;
            codeword_out<= 0;
            valid_out   <= 0;
        end else if (enable && valid_in) begin
            // Compute feedback: XOR input data with previous parity symbol
            feedback <= data_in ^ parity_0;
            // Update parity symbols using generator polynomial coefficients.
            // For parity_0, use coefficient corresponding to index 0;
            // for parity_1, update using the previous parity_1 value.
            parity_0 <= feedback ^ generator_polynomial(0);
            parity_1 <= parity_1 ^ generator_polynomial(1);
            // Construct the codeword by concatenating the data symbol and parity symbols.
            codeword_out <= {data_in, parity_0, parity_1};
            valid_out    <= 1'b1;
        end
    end

    // Function to select generator polynomial coefficients based on index.
    // For even indices, returns 8'h1D; for odd indices, returns 8'h33.
    function [DATA_WIDTH-1:0] generator_polynomial;
        input int index;
        begin
            if (index % 2 == 0)
                generator_polynomial = 8'h1D;
            else
                generator_polynomial = 8'h33;
        end
    endfunction

endmodule