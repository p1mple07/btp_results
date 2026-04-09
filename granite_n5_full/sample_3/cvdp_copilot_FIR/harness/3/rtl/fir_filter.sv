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
            shift_reg0 <= 16'd0;
            shift_reg1 <= 16'd0;
            shift_reg2 <= 16'd0;
            shift_reg3 <= 16'd0;
            shift_reg4 <= 16'd0;
            shift_reg5 <= 16'd0;
            shift_reg6 <= 16'd0;
            shift_reg7 <= 16'd0;

            coeff0 <= 16'd10;
            coeff1 <= 16'd12;
            coeff2 <= 16'd12;
            coeff3 <= 16'd12;
            coeff4 <= 16'd12;
            coeff5 <= 16'd12;
            coeff6 <= 16'd12;
            coeff7 <= 16'd12;
        end else begin
            shift_reg0 <= shift_reg1;
            shift_reg1 <= shift_reg2;
            shift_reg2 <= shift_reg3;
            shift_reg3 <= shift_reg4;
            shift_reg4 <= shift_reg5;
            shift_reg5 <= shift_reg6;
            shift_reg6 <= shift_reg7;
            shift_reg7 <= data_in;

            case(window_type)
                2'b00: begin
                    coeff0 <= 16'd10;
                    coeff1 <= 16'd12;
                    coeff2 <= 16'd12;
                    coeff3 <= 16'd12;
                    coeff4 <= 16'd12;
                    coeff5 <= 16'd12;
                    coeff6 <= 16'd12;
                    coeff7 <= 16'd12;
                end
                2'b01: begin
                    coeff0 <= 16'd2;
                    coeff1 <= 4;
                    coeff2 <= 8;
                    coeff3 <= 12;
                    coeff4 <= 12;
                    coeff5 <= 8;
                    coeff6 <= 4;
                    coeff7 <= 2;
                end
                2'b10: begin
                    coeff0 <= 16'd3;
                    coeff1 <= 6;
                    coeff2 <= 9;
                    coeff3 <= 11;
                    coeff4 <= 11;
                    coeff5 <= 9;
                    coeff6 <= 6;
                    coeff7 <= 3;
                end
                2'b11: begin
                    coeff0 <= 16'd1;
                    coeff1 <= 2;
                    coeff2 <= 5;
                    coeff3 <= 9;
                    coeff4 <= 9;
                    coeff5 <= 5;
                    coeff6 <= 2;
                    coeff7 <= 1;
                end
            endcase

            data_out <= (coeff0 * shift_reg0) + (coeff1 * shift_reg1) +
                        (coeff2 * shift_reg2) + (coeff3 * shift_reg3) +
                        (coeff4 * shift_reg4) + (coeff5 * shift_reg5) +
                        (coeff6 * shift_reg6) + (coeff7 * shift_reg7) >>> 4;
        end
    end

endmodule