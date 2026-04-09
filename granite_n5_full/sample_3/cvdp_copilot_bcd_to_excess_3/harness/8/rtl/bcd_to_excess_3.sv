module bcd_to_excess_3(
    input wire clk,               // Clock signal for synchronous operation.
    input wire rst,               // Reset signal for synchronous reset (active high).
    input wire enable,             // Enable signal to control the module operation.
    input wire [3:0] bcd,           // 4-bit Binary-Code Decimal input.
    output logic [3:0] excess3,    // 4-bit Excess-3 code output.
    output logic error,            // Error flag indicating invalid BCD input.
    output logic parity,          // Parity bit calculated as the XOR of all bits in the BCD input.
    output logic [1:0] error_code   // Error code indicating the nature of the error.
);

logic [3:0] excess3_calc;       // Internal calculation for the Excess-3 code.

// Combinatorial logic to calculate the Excess-3 code based on the BCD input.
always_comb begin
    // Check if the BCD input is valid.
    if (bcd inside {[0:9]}) begin
        // Calculate the Excess-3 code using the BCD input.
        excess3_calc = bcd;
    end else begin
        // Handle invalid inputs by setting the Excess-3 code to 0 and raising an error flag.
        excess3_calc = 4'b0000;
        error = 1'b1;
        error_code = 2'b01;
    end
    
    // Calculate the parity bit using the XOR of all bits in the BCD input.
    parity = ^bcd;
    
    // Assign the calculated values to the output ports.
    excess3 = excess3_calc;
end

// Sequential logic to handle the asynchronous reset and clock signals.
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset the output ports to their default values.
        excess3 <= 4'b0000;
        error <= 1'b0;
        error_code <= 2'b00;
    end
end

// Ensure the module behaves correctly when enable signal is de-asserted.
always_comb begin
    // Set the internal calculation result to 0 and raise an error flag when enable signal is de-asserted.
    excess3_calc = 4'b0000;
    error = 1'b0;
    error_code = 2'b00;
    
    // Calculate the Excess-3 code using the BCD input.
    excess3 = excess3_calc;
end

endmodule