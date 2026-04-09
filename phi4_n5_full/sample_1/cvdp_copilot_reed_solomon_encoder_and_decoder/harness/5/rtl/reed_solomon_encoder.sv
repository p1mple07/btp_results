module reed_solomon_encoder #(
    parameter DATA_WIDTH = 8,   // Width of input data symbols
    parameter N = 255,         // Total number of symbols in the codeword
    parameter K = 223          // Number of data symbols
) (
    input  wire                clk,
    input  wire                reset,
    input  wire                enable,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire                valid_in,
    output reg  [DATA_WIDTH-1:0] codeword_out,
    output reg                 valid_out,
    output reg  [DATA_WIDTH-1:0] parity_0,
    output reg  [DATA_WIDTH-1:0] parity_1
);

    localparam PARITY_SYMBOLS = N - K; // Number of parity symbols 

    // Internal registers for shift-register based encoding
    reg [DATA_WIDTH-1:0] feedback;
    reg [DATA_WIDTH-1:0] next_parity_0, next_parity_1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parity_0      <= 0;
            parity_1      <= 0;
            codeword_out  <= 0;
            valid_out     <= 0;
        end 
        else if (enable && valid_in) begin
            // Compute feedback from the input data symbol and the current parity_0
            feedback <= data_in ^ parity_0;
            // Compute new parity values using the generator polynomial coefficients.
            // Here, we use two coefficients: one for updating parity_0 and one for parity_1.
            next_parity_0 = parity_1 ^ (feedback & generator_polynomial(0));
            next_parity_1 = parity_0 ^ (feedback & generator_polynomial(1));
            // Update the parity registers
            parity_0 <= next_parity_0;
            parity_1 <= next_parity_1;
            // For demonstration, combine the data and parity symbols by XOR-ing them together.
            codeword_out <= data_in ^ parity_0 ^ parity_1;
            valid_out    <= 1;
        end
    end

    // Function to return the generator polynomial coefficient based on an index.
    // When index is 0, return 8'h1D; otherwise return 8'h33.
    function automatic [DATA_WIDTH-1:0] generator_polynomial;
       input int index;
       begin
          if (index == 0)
             generator_polynomial = 8'h1D;
          else
             generator_polynomial = 8'h33;
       end
    endfunction

endmodule