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
            // Reset logic
            data_out <= 16'b0;
            coeff0 <= 16'b0;
            coeff1 <= 16'b0;
            coeff2 <= 16'b0;
            coeff3 <= 16'b0;
            coeff4 <= 16'b0;
            coeff5 <= 16'b0;
            coeff6 <= 16'b0;
            coeff7 <= 16'b0;
            shift_reg0 <= 16'b0;
            shift_reg1 <= 16'b0;
            shift_reg2 <= 16'b0;
            shift_reg3 <= 16'b0;
            shift_reg4 <= 16'b0;
            shift_reg5 <= 16'b0;
            shift_reg6 <= 16'b0;
            shift_reg7 <= 16'b0;
        end else begin
            // Coefficient selection based on window type
            case (window_type)
                2'b00: begin
                    coeff0 <= 16'h10;
                    coeff1 <= 16'h11;
                    coeff2 <= 16'h12;
                    coeff3 <= 16'h13;
                    coeff4 <= 16'h14;
                    coeff5 <= 16'h15;
                    coeff6 <= 16'h16;
                    coeff7 <= 16'h17;
                end
                2'b01: begin
                    coeff0 <= 16'h2;
                    coeff1 <= 16'h4;
                    coeff2 <= 16'h8;
                    coeff3 <= 16'h12;
                    coeff4 <= 16'h12;
                    coeff5 <= 16'h8;
                    coeff6 <= 16'h4;
                    coeff7 <= 16'h2;
                end
                2'b10: begin
                    coeff0 <= 16'h3;
                    coeff1 <= 16'h6;
                    coeff2 <= 16'h9;
                    coeff3 <= 16'h11;
                    coeff4 <= 16'h11;
                    coeff5 <= 16'h9;
                    coeff6 <= 16'h6;
                    coeff7 <= 16'h3;
                end
                2'b11: begin
                    coeff0 <= 16'h1;
                    coeff1 <= 16'h2;
                    coeff2 <= 16'h5;
                    coeff3 <= 16'h9;
                    coeff4 <= 16'h9;
                    coeff5 <= 16'h5;
                    coeff6 <= 16'h2;
                    coeff7 <= 16'h1;
                end
                default: begin
                    // Default case if window_type is not recognized
                    // You can add error handling or default coefficients here
                end
            endcase

            // Shift register updates
            shift_reg0 <= shift_reg1;
            shift_reg1 <= shift_reg2;
            shift_reg2 <= shift_reg3;
            shift_reg3 <= shift_reg4;
            shift_reg4 <= shift_reg5;
            shift_reg5 <= shift_reg6;
            shift_reg6 <= shift_reg7;
            shift_reg7 <= data_in;

            // Output calculation
            data_out <= (coeff0 * shift_reg0 + coeff1 * shift_reg1 + coeff2 * shift_reg2 +
                         coeff3 * shift_reg3 + coeff4 * shift_reg4 + coeff5 * shift_reg5 +
                         coeff6 * shift_reg6 + coeff7 * shift_reg7) >>> 4;
        end
    end
endmodule
