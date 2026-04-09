module fir_filter (
    input wire clk,
    input wire reset,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    input wire [1:0] window_type
);

    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3, shift_reg4, shift_reg5, shift_reg6, shift_reg7;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 16'h0000;
            coeff0 = 10; coeff1 = 11; coeff2 = 12; coeff3 = 13; coeff4 = 14;
            coeff5 = 15; coeff6 = 16; coeff7 = 17;
            shift_reg0 = 0; shift_reg1 = 0; shift_reg2 = 0; shift_reg3 = 0;
            shift_reg4 = 0; shift_reg5 = 0; shift_reg6 = 0; shift_reg7 = 0;
        end else begin
            case (window_type)
                "2'b00": begin
                    coeff0 = 10; coeff1 = 11; coeff2 = 12; coeff3 = 13; coeff4 = 14;
                    coeff5 = 15; coeff6 = 16; coeff7 = 17;
                end
                "2'b01": begin
                    coeff0 = 10; coeff1 = 11; coeff2 = 12; coeff3 = 12; coeff4 = 11;
                    coeff5 = 11; coeff6 = 10; coeff7 = 12;
                end
                "2'b10": begin
                    coeff0 = 11; coeff1 = 11; coeff2 = 11; coeff3 = 11; coeff4 = 11;
                    coeff5 = 11; coeff6 = 11; coeff7 = 11;
                end
                "2'b11": begin
                    coeff0 = 10; coeff1 = 11; coeff2 = 12; coeff3 = 13; coeff4 = 14;
                    coeff5 = 15; coeff6 = 15; coeff7 = 14;
                end
            endcase

            // Shift all registers by one clock cycle
            shift_reg0 <= shift_reg0 << 1;
            shift_reg1 <= shift_reg1 << 1;
            shift_reg2 <= shift_reg2 << 1;
            shift_reg3 <= shift_reg3 << 1;
            shift_reg4 <= shift_reg4 << 1;
            shift_reg5 <= shift_reg5 << 1;
            shift_reg6 <= shift_reg6 << 1;
            shift_reg7 <= shift_reg7 << 1;

            // Compute output by summing products and normalising
            data_out <= (coeff0 * shift_reg0 + coeff1 * shift_reg1 +
                          coeff2 * shift_reg2 + coeff3 * shift_reg3 +
                          coeff4 * shift_reg4 +
                          coeff5 * shift_reg5 +
                          coeff6 * shift_reg6 +
                          coeff7 * shift_reg7) >> 4;
        end
    end

endmodule
