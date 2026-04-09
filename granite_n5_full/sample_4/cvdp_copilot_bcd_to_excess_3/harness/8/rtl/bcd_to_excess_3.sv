module bcd_to_excess_3(
    input [3:0] clk,             // Clock signal
    input rst,                 // Asynchronous reset active high
    input enable,              // Module enable
    input [3:0] bcd,             // BCD input
    output reg [3:0] excess3,   // 4-bit Excess-3 code output
    output reg error,           // Error flag to indicate invalid input
    output reg parity,         // Parity bit calculated by XORing all bits in the BCD input
    output reg [1:0] error_code  // Error code indicating the nature of the error
);

reg [3:0] excess3_reg;       // Register to hold the Excess-3 code value
reg [3:0] bcd_reg;            // Register to hold the current BCD input value
reg parity_reg;           // Register to hold the parity bit value
reg error_flag;            // Register to hold the error flag value

always @(posedge clk or posedge rst) begin
    if (rst) begin
        excess3_reg <= 4'b0000;
        bcd_reg <= 4'b0000;
        parity_reg <= 1'b0;
        error_flag <= 1'b0;
        error_code <= 2'b00;
    end else if (enable) begin
        // Check for valid BCD input
        if (bcd < 4'b0000 || bcd > 4'b1111) begin
            excess3_reg <= 4'b0000;
            bcd_reg <= 4'b0000;
            parity_reg <= 1'b0;
            error_flag <= 1'b1;
            error_code <= 2'b01;
        end else begin
            // Calculate Excess-3 code
            excess3_reg <= (bcd[3:0] + 1) & {1'b0, ~bcd[3:0]};
            bcd_reg <= bcd;

            // Calculate parity bit
            parity_reg <= ~(bcd[3:0] ^ bcd[3:0]);

            // Calculate error flags and codes
            if ((bcd[3:0]!= bcd[3:0]) then
                error_flag <= 1'b1;
                error_code <= 2'b00;
            else
                error_flag <= 1'b0;
                error_code <= 2'b00;
        end if

        // Update the output ports based on the calculated parity bit
        parity_out <= parity_reg;
        error_out <= error_flag;
    end
endmodule