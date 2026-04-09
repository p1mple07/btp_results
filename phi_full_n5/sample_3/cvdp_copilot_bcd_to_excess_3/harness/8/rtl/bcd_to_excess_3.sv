module bcd_to_excess_3(
    input clk,
    input rst,
    input enable,
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error,
    output reg parity,
    output reg [1:0] error_code
);

    // Local variables
    reg [3:0] temp_excess3;

    // Synchronous reset
    always @ (posedge clk) begin
        if (rst) begin
            excess3 <= 4'b0000;
            error <= 1'b0;
            parity <= 1'b0;
            error_code <= 2'b00;
        end else begin
            if (enable) begin
                // Valid input handling
                case (bcd)
                    4'b0000: temp_excess3 = 4'b0011;
                    4'b0001: temp_excess3 = 4'b0100;
                    4'b0010: temp_excess3 = 4'b0101;
                    4'b0011: temp_excess3 = 4'b0110;
                    4'b0100: temp_excess3 = 4'b0111;
                    4'b0101: temp_excess3 = 4'b1000;
                    4'b0110: temp_excess3 = 4'b1001;
                    4'b0111: temp_excess3 = 4'b1010;
                    4'b1000: temp_excess3 = 4'b1011;
                    4'b1001: temp_excess3 = 4'b1100;
                    default: begin
                        excess3 <= 4'b0000;
                        error <= 1'b1;
                        parity <= 1'b0;
                        error_code <= 2'b01;
                    end
                endcase

                // Parity calculation
                parity <= bcd[3] ^ bcd[2] ^ bcd[1] ^ bcd[0];

                // Setting the outputs
                excess3 <= temp_excess3;
                error <= 1'b0; // Clear error flag for valid inputs
                error_code <= 2'b00; // No error code for valid inputs
            end
        end
    end

endmodule
