module fir_filter (
    input wire clk,                  
    input wire reset,                
    input wire [15:0] data_in,       
    output reg [15:0] data_out,      
    input wire [1:0] window_type     
);

    // Coefficient registers for each tap
    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    // Shift registers for data delay
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3, shift_reg4, shift_reg5, shift_reg6, shift_reg7;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Comprehensive reset: clear all internal states and output
            data_out          <= 16'd0;
            shift_reg0        <= 16'd0;
            shift_reg1        <= 16'd0;
            shift_reg2        <= 16'd0;
            shift_reg3        <= 16'd0;
            shift_reg4        <= 16'd0;
            shift_reg5        <= 16'd0;
            shift_reg6        <= 16'd0;
            shift_reg7        <= 16'd0;
            coeff0            <= 16'd0;
            coeff1            <= 16'd0;
            coeff2            <= 16'd0;
            coeff3            <= 16'd0;
            coeff4            <= 16'd0;
            coeff5            <= 16'd0;
            coeff6            <= 16'd0;
            coeff7            <= 16'd0;
        end else begin
            // Dynamic coefficient selection based on window_type
            case (window_type)
                2'b00: begin  // Rectangular Window: coefficients 10 to 17
                    coeff0 = 16'd10;
                    coeff1 = 16'd11;
                    coeff2 = 16'd12;
                    coeff3 = 16'd13;
                    coeff4 = 16'd14;
                    coeff5 = 16'd15;
                    coeff6 = 16'd16;
                    coeff7 = 16'd17;
                end
                2'b01: begin  // Hanning Window: [2, 4, 8, 12, 12, 8, 4, 2]
                    coeff0 = 16'd2;
                    coeff1 = 16'd4;
                    coeff2 = 16'd8;
                    coeff3 = 16'd12;
                    coeff4 = 16'd12;
                    coeff5 = 16'd8;
                    coeff6 = 16'd4;
                    coeff7 = 16'd2;
                end
                2'b10: begin  // Hamming Window: [3, 6, 9, 11, 11, 9, 6, 3]
                    coeff0 = 16'd3;
                    coeff1 = 16'd6;
                    coeff2 = 16'd9;
                    coeff3 = 16'd11;
                    coeff4 = 16'd11;
                    coeff5 = 16'd9;
                    coeff6 = 16'd6;
                    coeff7 = 16'd3;
                end
                2'b11: begin  // Blackman Window: [1, 2, 5, 9, 9, 5, 2, 1]
                    coeff0 = 16'd1;
                    coeff1 = 16'd2;
                    coeff2 = 16'd5;
                    coeff3 = 16'd9;
                    coeff4 = 16'd9;
                    coeff5 = 16'd5;
                    coeff6 = 16'd2;
                    coeff7 = 16'd1;
                end
            endcase

            // FIR filter output calculation:
            // Multiply each delayed sample by its corresponding coefficient and sum the results.
            // A right shift by 4 bits is applied for normalization.
            reg [31:0] sum;
            sum = (shift_reg0 * coeff0) +
                  (shift_reg1 * coeff1) +
                  (shift_reg2 * coeff2) +
                  (shift_reg3 * coeff3) +
                  (shift_reg4 * coeff4) +
                  (shift_reg5 * coeff5) +
                  (shift_reg6 * coeff6) +
                  (shift_reg7 * coeff7);
            data_out <= sum >> 4;

            // Cascade data_in through the eight shift registers.
            // The oldest sample is shifted out and data_in enters at the beginning.
            shift_reg7 <= shift_reg6;
            shift_reg6 <= shift_reg5;
            shift_reg5 <= shift_reg4;
            shift_reg4 <= shift_reg3;
            shift_reg3 <= shift_reg2;
            shift_reg2 <= shift_reg1;
            shift_reg1 <= shift_reg0;
            shift_reg0 <= data_in;
        end
    end

endmodule