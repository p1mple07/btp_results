module reed_solomon_encoder #(
    parameter DATA_WIDTH = 8,   // Width of input data symbols
    parameter N = 255,         // Total number of symbols in the codeword
    parameter K = 223          // Number of data symbols
) (
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 enable,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire                 valid_in,
    // The complete codeword is formed by concatenating the data symbol with the two parity symbols.
    output reg  [(3*DATA_WIDTH)-1:0] codeword_out,
    output reg                  valid_out,
    output reg  [DATA_WIDTH-1:0] parity_0,
    output reg  [DATA_WIDTH-1:0] parity_1
);

    // Number of parity symbols (for a full RS encoder this would be N-K, but here we use 2 parity outputs)
    localparam PARITY_SYMBOLS = N - K;

    // Internal registers for shift-register based encoding
    reg [DATA_WIDTH-1:0] feedback;
    reg [DATA_WIDTH-1:0] shift_reg;  // Shift register to hold recent symbols
    reg [7:0] counter;               // Counter used to select the generator polynomial coefficient

    // Main encoding process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear all registers on reset
            parity_0      <= '0;
            parity_1      <= '0;
            codeword_out  <= '0;
            valid_out     <= 1'b0;
            shift_reg     <= '0;
            counter       <= '0;
        end 
        else if (enable && valid_in) begin
            // Shift in the new data symbol into the shift register
            shift_reg <= { shift_reg[DATA_WIDTH-2:0], data_in };

            // Increment the counter to use for selecting the generator polynomial coefficient
            counter <= counter + 1;

            // Compute feedback value using the generator polynomial.
            // In this simplified example, the feedback is computed as the XOR of the input data and
            // the polynomial coefficient returned by generator_polynomial.
            feedback <= data_in ^ generator_polynomial(counter[7:0]);

            // Update the parity registers by XORing the feedback value.
            parity_0 <= parity_0 ^ feedback;
            parity_1 <= parity_1 ^ feedback;

            // Form the complete codeword by concatenating the data symbol and the two parity symbols.
            codeword_out <= { data_in, parity_0, parity_1 };

            // Indicate that a valid codeword is available.
            valid_out <= 1'b1;
        end
    end

    // Function to return the generator polynomial coefficient.
    // For this example, the function selects between 8'h1D and 8'h33 based on the provided index.
    function automatic [DATA_WIDTH-1:0] generator_polynomial(input int index);
       if (index % 2 == 0)
           return 8'h1D;
       else
           return 8'h33;
    endfunction

endmodule