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
            coeff0 = 0; coeff1 = 0; coeff2 = 0; coeff3 = 0; coeff4 = 0;
            coeff5 = 0; coeff6 = 0; coeff7 = 0;
            shift_reg0 <= 0; shift_reg1 <= 0; shift_reg2 <= 0;
            shift_reg3 <= 0; shift_reg4 <= 0; shift_reg5 <= 0;
            shift_reg6 <= 0; shift_reg7 <= 0;
            data_out <= 0;
        end else begin
            shift_reg0 <= shift_reg0 << 1;
            shift_reg1 <= shift_reg1 << 1;
            shift_reg2 <= shift_reg2 << 1;
            shift_reg3 <= shift_reg3 << 1;
            shift_reg4 <= shift_reg4 << 1;
            shift_reg5 <= shift_reg5 << 1;
            shift_reg6 <= shift_reg6 << 1;
            shift_reg7 <= shift_reg7 << 1;

            data_out = (coeff0 * shift_reg0) +
                       (coeff1 * shift_reg1) +
                       (coeff2 * shift_reg2) +
                       (coeff3 * shift_reg3) +
                       (coeff4 * shift_reg4) +
                       (coeff5 * shift_reg5) +
                       (coeff6 * shift_reg6) +
                       (coeff7 * shift_reg7);

            data_out <= data_out >> 4;
        end
    end

endmodule
