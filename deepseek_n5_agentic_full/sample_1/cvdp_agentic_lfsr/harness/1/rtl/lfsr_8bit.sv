module lfsr_8bit (
    input wire clk,
    input wire rst,
    input wire [7:0] seed,  // User-defined initial seed
    output reg [7:0] lfsr_out
);

    reg [7:0] state;  // State holds the current LFSR value

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= seed;  // Load the seed on reset
        else
            state <= {state[6:0], (state[7] ^ state[5] ^ state[4])};  // Corrected feedback taps and shift
        lfsr_out <= state;  // Output the current state
    end
endmodule