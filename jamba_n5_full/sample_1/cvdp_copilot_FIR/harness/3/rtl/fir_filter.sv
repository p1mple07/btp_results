module fir_filter (
    input wire clk,
    input wire reset,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    input wire [1:0] window_type
);

    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3, shift_reg4, shift_reg5, shift_reg6, shift_reg7;
    reg [1:0] data_in_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            coeff0 = 0; coeff1 = 0; coeff2 = 0; coeff3 = 0; coeff4 = 0; coeff5 = 0; coeff6 = 0; coeff7 = 0;
            shift_reg0 = 0; shift_reg1 = 0; shift_reg2 = 0; shift_reg3 = 0; shift_reg4 = 0; shift_reg5 = 0; shift_reg6 = 0; shift_reg7 = 0;
            data_in_reg = 0;
        end else begin
            shift_reg0 <= data_in;
            shift_reg1 <= shift_reg0;
            shift_reg2 <= shift_reg1;
            shift_reg3 <= shift_reg2;
            shift_reg4 <= shift_reg3;
            shift_reg5 <= shift_reg4;
            shift_reg6 <= shift_reg5;
            shift_reg7 <= shift_reg6;

            case (window_type)
                2'b00: coeff0 = 10; coeff1 = 11; coeff2 = 12; coeff3 = 13; coeff4 = 14; coeff5 = 15; coeff6 = 16; coeff7 = 17;
                2'b01: coeff0 = 2;  coeff1 = 4;  coeff2 = 8;  coeff3 = 12; coeff4 = 12; coeff5 = 8;  coeff6 = 4;  coeff7 = 2;
                2'b10: coeff0 = 3;  coeff1 = 6;  coeff2 = 9;  coeff3 = 11; coeff4 = 11; coeff5 = 9;  coeff6 = 6;  coeff7 = 3;
                2'b11: coeff0 = 1;  coeff1 = 2;  coeff2 = 5;  coeff3 = 9;  coeff4 = 9; coeff5 = 5;  coeff6 = 2;  coeff7 = 1;
            endcase

            assign data_out = (coeff0 * shift_reg0 + coeff1 * shift_reg1 + coeff2 * shift_reg2 + coeff3 * shift_reg3 +
                               coeff4 * shift_reg4 + coeff5 * shift_reg5 + coeff6 * shift_reg6 + coeff7 * shift_reg7) >> 4;
        end
    end
endmodule
