module fir_filter (
    input wire clk,                  // Clock signal
    input wire reset,                // Asynchronous reset
    input wire [15:0] data_in,       // Input data
    output reg [15:0] data_out,      // Filtered output data
    input wire [1:0] window_type     // Window type selector: 00-Rectangular, 01-Hanning, 10-Hamming, 11-Blackman
);

    // Coefficients for FIR filter
    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    // Shift registers for data delay
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3, shift_reg4, shift_reg5, shift_reg6, shift_reg7;
    // 32-bit accumulator for the sum of products
    reg [31:0] sum;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all shift registers and output to zero
            data_out      <= 16'd0;
            shift_reg0    <= 16'd0;
            shift_reg1    <= 16'd0;
            shift_reg2    <= 16'd0;
            shift_reg3    <= 16'd0;
            shift_reg4    <= 16'd0;
            shift_reg5    <= 16'd0;
            shift_reg6    <= 16'd0;
            shift_reg7    <= 16'd0;
        end else begin
            // Cascade data_in through the eight shift registers
            shift_reg7 <= shift_reg6;
            shift_reg6 <= shift_reg5;
            shift_reg5 <= shift_reg4;
            shift_reg4 <= shift_reg3;
            shift_reg3 <= shift_reg2;
            shift_reg2 <= shift_reg1;
            shift_reg1 <= shift_reg0;
            shift_reg0 <= data_in;

            // Dynamically select filter coefficients based on window_type
            case (window_type)
                2'b00: begin  // Rectangular Window: coefficients 10 to 17
                    coeff0 <= 16'd10;
                    coeff1 <= 16'd11;
                    coeff2 <= 16'd12;
                    coeff3 <= 16'd13;
                    coeff4 <= 16'd14;
                    coeff5 <= 16'd15;
                    coeff6 <= 16'd16;
                    coeff7 <= 16'd17;
                end
                2'b01: begin  // Hanning Window: tapered coefficients [2, 4, 8, 12, 12, 8, 4, 2]
                    coeff0 <= 16'd2;
                    coeff1 <= 16'd4;
                    coeff2 <= 16'd8;
                    coeff3 <= 16'd12;
                    coeff4 <= 16'd12;
                    coeff5 <= 16'd8;
                    coeff6 <= 16'd4;
                    coeff7 <= 16'd2;
                end
                2'b10: begin  // Hamming Window: coefficients [3, 6, 9, 11, 11, 9, 6, 3]
                    coeff0 <= 16'd3;
                    coeff1 <= 16'd6;
                    coeff2 <= 16'd9;
                    coeff3 <= 16'd11;
                    coeff4 <= 16'd11;
                    coeff5 <= 16'd9;
                    coeff6 <= 16'd6;
                    coeff7 <= 16'd3;
                end
                2'b11: begin  // Blackman Window: coefficients [1, 2, 5, 9, 9, 5, 2, 1]
                    coeff0 <= 16'd1;
                    coeff1 <= 16'd2;
                    coeff2 <= 16'd5;
                    coeff3 <= 16'd9;
                    coeff4 <= 16'd9;
                    coeff5 <= 16'd5;
                    coeff6 <= 16'd2;
                    coeff7 <= 16'd1;
                end
                default: begin  // Default to Rectangular Window if unknown
                    coeff0 <= 16'd10;
                    coeff1 <= 16'd11;
                    coeff2 <= 16'd12;
                    coeff3 <= 16'd13;
                    coeff4 <= 16'd14;
                    coeff5 <= 16'd15;
                    coeff6 <= 16'd16;
                    coeff7 <= 16'd17;
                end
            endcase

            // Calculate the FIR filter output by summing the product of each shift register and its coefficient
            sum = shift_reg0 * coeff0 +
                  shift_reg1 * coeff1 +
                  shift_reg2 * coeff2 +
                  shift_reg3 * coeff3 +
                  shift_reg4 * coeff4 +
                  shift_reg5 * coeff5 +
                  shift_reg6 * coeff6 +
                  shift_reg7 * coeff7;

            // Normalize the sum with a right shift of 4 bits
            data_out <= sum >> 4;
        end
    end
endmodule