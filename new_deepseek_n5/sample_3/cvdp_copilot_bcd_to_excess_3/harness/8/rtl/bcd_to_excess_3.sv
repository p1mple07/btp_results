module bcd_to_excess_3(
    input clock,
    input rst,
    input enable,
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error,
    output reg parity,
    output reg [1:0] error_code
);

    // State machine to handle synchronous reset and enable states
    statecase state
        // Reset state
        when (rst == 1'b1) begin
            excess3 = 4'b0000;
            error = 0'b0;
            parity = 0'b0;
            error_code = 2'b00;
            state = '0; // Default state
        end

        // Active state
        when (enable == 1'b1) begin
            // Validate BCD input
            if (bcd >= 4'b0000 && bcd <= 4'b1001) begin
                // Calculate Excess-3 code
                excess3 = compute_excess3(bcd);
                // Calculate parity
                parity = bcd[3] ^ bcd[2] ^ bcd[1] ^ bcd[0];
                // No error
                error_code = 2'b00;
            else begin
                // Invalid input
                excess3 = 4'b0000;
                error = 1'b1;
                parity = 0'b0;
                error_code = 2'b01;
            end
        end

        default: state = '0;
    endcase

    // Function to compute Excess-3 code
    function [3:0] compute_excess3(input [3:0] bcd) begin
        reg [3:0] sum;
        sum = bcd + 3;
        return sum;
    endfunction
endmodule