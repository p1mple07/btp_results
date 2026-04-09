module fir_filter (
    input wire clk,
    input wire reset,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    input wire [1:0] window_type
);

    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3, shift_reg4, shift_reg5, shift_reg6, shift_reg7;
    reg data_in_ready;

    initial begin
        coeff0 = 10; coeff1 = 11; coeff2 = 12; coeff3 = 13;
        coeff4 = 14; coeff5 = 15; coeff6 = 16; coeff7 = 17;
        shift_reg0 = 0; shift_reg1 = 0; shift_reg2 = 0; shift_reg3 = 0;
        shift_reg4 = 0; shift_reg5 = 0; shift_reg6 = 0; shift_reg7 = 0;
        data_in_ready = 1'b0;
    end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_out <= 0;
        shift_reg0 = 0; shift_reg1 = 0; shift_reg2 = 0; shift_reg3 = 0;
        shift_reg4 = 0; shift_reg5 = 0; shift_reg6 = 0; shift_reg7 = 0;
        coeff0 = 10; coeff1 = 11; coeff2 = 12; coeff3 = 13;
        coeff4 = 14; coeff5 = 15; coeff6 = 16; coeff7 = 17;
        data_in_ready = 1'b0;
    end else begin
        if (data_in_ready) begin
            shift_reg0 <= data_in[0];
            shift_reg1 <= shift_reg0 + data_in[1];
            shift_reg2 <= shift_reg1 + data_in[2];
            shift_reg3 <= shift_reg2 + data_in[3];
            shift_reg4 <= shift_reg3 + data_in[4];
            shift_reg5 <= shift_reg4 + data_in[5];
            shift_reg6 <= shift_reg5 + data_in[6];
            shift_reg7 <= shift_reg6 + data_in[7];
        end else begin
            // Not ready
        end

        data_out = { shift_reg0, shift_reg1, shift_reg2, shift_reg3,
                     shift_reg4, shift_reg5, shift_reg6, shift_reg7 };

        data_out <= data_out >> 4;
    end
end

endmodule
