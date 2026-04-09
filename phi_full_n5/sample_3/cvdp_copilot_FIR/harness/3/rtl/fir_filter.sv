module fir_filter (
    input wire clk,                  // Clock signal
    input wire reset,                // Asynchronous reset
    input wire [15:0] data_in,       // Input data
    output reg [15:0] data_out,      // Filtered output data
    input wire [1:0] window_type     // Window type selector: 0-Rectangular, 1-Hanning, 2-Hamming, 3-Blackman
);

    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3, shift_reg4, shift_reg5, shift_reg6, shift_reg7;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logic to zero all registers and output
            shift_reg0 <= 16'b0;
            shift_reg1 <= 16'b0;
            shift_reg2 <= 16'b0;
            shift_reg3 <= 16'b0;
            shift_reg4 <= 16'b0;
            shift_reg5 <= 16'b0;
            shift_reg6 <= 16'b0;
            shift_reg7 <= 16'b0;
            data_out <= 16'b0;
        end else begin
            // Shift register updates
            shift_reg0 <= shift_reg1;
            shift_reg1 <= shift_reg2;
            shift_reg2 <= shift_reg3;
            shift_reg3 <= shift_reg4;
            shift_reg4 <= shift_reg5;
            shift_reg5 <= shift_reg6;
            shift_reg6 <= shift_reg7;
            shift_reg7 <= data_in;

            // Coefficient selection based on window type
            case (window_type)
                2'b00: coeff0 = 16'h0A; coeff1 = 16'h0B; coeff2 = 16'h0C; coeff3 = 16'h0D; coeff4 = 16'h0E; coeff5 = 16'h0F; coeff6 = 16'h0G; coeff7 = 16'h0H;
                2'b01: coeff0 = 16'h02; coeff1 = 16'h04; coeff2 = 16'h08; coeff3 = 16'h0A; coeff4 = 16'h0A; coeff5 = 16'h08; coeff6 = 16'h04; coeff7 = 16'h02;
                2'b10: coeff0 = 16'h03; coeff1 = 16'h06; coeff2 = 16'h09; coeff3 = 16'h0A; coeff4 = 16'h0A; coeff5 = 16'h09; coeff6 = 16'h06; coeff7 = 16'h03;
                2'b11: coeff0 = 16'h01; coeff1 = 16'h02; coeff2 = 16'h05; coeff3 = 16'h0A; coeff4 = 16'h0A; coeff5 = 16'h05; coeff6 = 16'h02; coeff7 = 16'h01;
                default: coeff0 = 16'h00; coeff1 = 16'h00; coeff2 = 16'h00; coeff3 = 16'h00; coeff4 = 16'h00; coeff5 = 16'h00; coeff6 = 16'h00; coeff7 = 16'h00;
            endcase

            // Output calculation
            data_out <= (coeff0 * shift_reg0 + coeff1 * shift_reg1 + coeff2 * shift_reg2 + coeff3 * shift_reg3 + coeff4 * shift_reg4 + coeff5 * shift_reg5 + coeff6 * shift_reg6 + coeff7 * shift_reg7) >>> 4;
        end
    end
endmodule
