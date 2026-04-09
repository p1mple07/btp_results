module fir_filter (
    input wire clk,                  // Clock signal
    input wire reset,                // Asynchronous reset
    input wire [15:0] data_in,       // Input data
    output reg [15:0] data_out,      // Filtered output data
    input wire [1:0] window_type     // Window type selector: 0-Rectangular, 1-Hanning, 2-Hamming, 3-Blackman
);

    reg [15:0] coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7;
    reg [15:0] shift_reg0, shift_reg1, shift_reg2, shift_reg3, shift_reg4, shift_reg5, shift_reg6, shift_reg7;

    always @* begin
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
            coeff3 <= 16'd8;
            coeff4 <= 16'd4;
            coeff5 <= 16'd2;
            coeff6 <= 16'd1;
            coeff7 <= 16'd0;

        end else begin
            shift_reg0 <= shift_reg1;
            shift_reg1 <= shift_reg2;
            shift_reg2 <= shift_reg3;
            shift_reg3 <= shift_reg4;
            shift_reg4 <= shift_reg5;
            shift_reg5 <= shift_reg6;
            shift_reg6 <= shift_reg7;
            shift_reg7 <= data_in;

            unique case(window_type)
                2'b00: begin
                    coeff0 <= 16'd10;
                    coeff1 <= 16'd12;
                    coeff2 <= 16'd12;
                    coeff3 <= 16'd8;
                    coeff4 <= 16'd4;
                    coeff5 <= 16'd2;
                    coeff6 <= 16'd1;
                    coeff7 <= 16'd0;
                end
                2'b01: begin
                    coeff0 <= 16'd3;
                    coeff1 <= 16'd6;
                    coeff2 <= 16'd9;
                    coeff3 <= 16'd11;
                    coeff4 <= 16'd11;
                    coeff5 <= 16'd9;
                    coeff6 <= 16'd6;
                    coeff7 <= 16'd3;
                end
                2'b10: begin
                    coeff0 <= 16'd2;
                    coeff1 <= 16'd4;
                    coeff2 <= 16'd8;
                    coeff3 <= 16'd12;
                    coeff4 <= 16'd12;
                    coeff5 <= 16'd8;
                    coeff6 <= 16'd4;
                    coeff7 <= 16'd2;
                end
                2'b11: begin
                    coeff0 <= 16'd1;
                    coeff1 <= 16'd2;
                    coeff2 <= 16'd5;
                    coeff3 <= 16'd9;
                    coeff4 <= 16'd9;
                    coeff5 <= 16'd5;
                    coeff6 <= 16'd2;
                    coeff7 <= 16'd1;
                end
            endcase
        end
    end

    assign data_out = (coeff7 * shift_reg7) + (coeff6 * shift_reg6) + (coeff5 * shift_reg5) +
                       (coeff4 * shift_reg4) + (coeff3 * shift_reg3) + (coeff2 * shift_reg2) +
                       (coeff1 * shift_reg1) + (coeff0 * shift_reg0) >>> 4;

endmodule