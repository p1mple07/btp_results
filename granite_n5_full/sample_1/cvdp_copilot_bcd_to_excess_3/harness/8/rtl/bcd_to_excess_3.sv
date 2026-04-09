module bcd_to_excess_3(
    input [3:0] clk,          // Clock signal for synchronous operation
    input rst,               // Synchronous reset signal (active high)
    input enable,           // Enable signal to control module operation
    input [3:0] bcd,          // 4-bit BCD input
    output reg [3:0] excess3, // 4-bit Excess-3 output
    output reg error,          // Error flag to indicate invalid input
    output reg parity,         // Parity bit calculated as the XOR of all bits in the BCD input
    output reg [1:0] error_code // Error code indicating the nature of the error
);

reg [3:0] temp_excess3;   // Temporary storage for Excess-3 output during calculations
reg parity_flag;       // Flag to indicate whether the BCD input has even or odd parity
wire [3:0] parity_mask;   // Mask to extract the parity bit from the BCD input

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        excess3 <= 4'b0000;
        error <= 1'b0;
        parity <= 1'b0;
        error_code <= 2'b00;
    end else if (enable) begin
        if (bcd >= 4'b0000 && bcd < 4'b1000) begin
            temp_excess3 <= bcd;
            error <= 1'b0;
            error_code <= 2'b00;
            
            // Calculate the parity bit using the XOR logic
            parity_mask <= 4'b1111;
            parity_flag <= 1'b0;
            for (int i=3; i>=0; i--) begin
                if (bcd[i] == 1) begin
                    parity_flag <= ~parity_flag;
                end
            end

            // Update the Excess-3 code output
            // based on the parity bit calculated above.
            if (parity_flag == 1'b0) begin
                excess3 <= {bcd[3:0], 2'b00};
            end else if (parity_flag == 1'b1) begin
                excess3 <= {bcd[3:0], 2'b00}
            end else begin
                error <= 1'b1;
                error_code <= 2'b10;
            end

        end
    end
endmodule