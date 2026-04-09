module fir_filter (
    input  wire         clk,                  // Clock signal
    input  wire         reset,                // Asynchronous reset
    input  wire [15:0]  data_in,              // 16-bit input data
    output reg  [15:0]  data_out,             // 16-bit filtered output data
    input  wire [1:0]   window_type           // Window type selector: 0-Rectangular, 1-Hanning, 2-Hamming, 3-Blackman
);

    // Filter coefficients
    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    // Shift registers for delaying the input data
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3,
               shift_reg4, shift_reg5, shift_reg6, shift_reg7;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all shift registers and output to zero
            shift_reg0 <= 16'd0;
            shift_reg1 <= 16'd0;
            shift_reg2 <= 16'd0;
            shift_reg3 <= 16'd0;
            shift_reg4 <= 16'd0;
            shift_reg5 <= 16'd0;
            shift_reg6 <= 16'd0;
            shift_reg7 <= 16'd0;
            data_out   <= 16'd0;
        end else begin
            // Cascade data_in through the shift registers
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
                2'b00: begin
                    coeff0 = 16'd10;
                    coeff1 = 16'd11;
                    coeff2 = 16'd12;
                    coeff3 = 16'd13;
                    coeff4 = 16'd14;
                    coeff5 = 16'd15;
                    coeff6 = 16'd16;
                    coeff7 = 16'd17;
                end
                2'b01: begin
                    coeff0 = 16'd2;
                    coeff1 = 16'd4;
                    coeff2 = 16'd8;
                    coeff3 = 16'd12;
                    coeff4 = 16'd12;
                    coeff5 = 16'd8;
                    coeff6 = 16'd4;
                    coeff7 = 16'd2;
                end
                2'b10: begin
                    coeff0 = 16'd3;
                    coeff1 = 16'd6;
                    coeff2 = 16'd9;
                    coeff3 = 16'd11;
                    coeff4 = 16'd11;
                    coeff5 = 16'd9;
                    coeff6 = 16'd6;
                    coeff7 = 16'd3;
                end
                2'b11: begin
                    coeff0 = 16'd1;
                    coeff1 = 16'd2;
                    coeff2 = 16'd5;
                    coeff3 = 16'd9;
                    coeff4 = 16'd9;
                    coeff5 = 16'd5;
                    coeff6 = 16'd2;
                    coeff7 = 16'd1;
                end
                default: begin
                    // Default to rectangular window if an undefined value is provided
                    coeff0 = 16'd10;
                    coeff1 = 16'd11;
                    coeff2 = 16'd12;
                    coeff3 = 16'd13;
                    coeff4 = 16'd14;
                    coeff5 = 16'd15;
                    coeff6 = 16'd16;
                    coeff7 = 16'd17;
                end
            endcase

            // Calculate the FIR filter output:
            // Sum the products of each shift register and its corresponding coefficient.
            // Use a 32-bit accumulator to handle the multiplication results.
            reg [31:0] sum;
            sum = (shift_reg0 * coeff0) +
                  (shift_reg1 * coeff1) +
                  (shift_reg2 * coeff2) +
                  (shift_reg3 * coeff3) +
                  (shift_reg4 * coeff4) +
                  (shift_reg5 * coeff5) +
                  (shift_reg6 * coeff6) +
                  (shift_reg7 * coeff7);
            // Normalize the result by performing a right shift of 4 bits
            data_out <= sum >>> 4;
        end
    end

endmodule