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
            shift_reg0 <= 16'h0000;
            shift_reg1 <= 16'h0000;
            shift_reg2 <= 16'h0000;
            shift_reg3 <= 16'h0000;
            shift_reg4 <= 16'h0000;
            shift_reg5 <= 16'h0000;
            shift_reg6 <= 16'h0000;
            shift_reg7 <= 16'h0000;
            coeff0 <= 16'h000a;
            coeff1 <= 16'h0013;
            coeff2 <= 16'h0022;
            coeff3 <= 16'h0031;
            coeff4 <= 16'h003a;
            coeff5 <= 16'h003a;
            coeff6 <= 16'h0031;
            coeff7 <= 16'h0022;
        end else begin
            case (window_type)
                2'b00: begin
                    coeff0 <= 16'h000a;
                    coeff1 <= 16'h0013;
                    coeff2 <= 16'h0022;
                    coeff3 <= 16'h0031;
                    coeff4 <= 16'h003a;
                    coeff5 <= 16'h003a;
                    coeff6 <= 16'h0031;
                    coeff7 <= 16'h0022;
                end
                2'b01: begin
                    coeff0 <= 16'h0008;
                    coeff1 <= 16'h0011;
                    coeff2 <= 16'h001e;
                    coeff3 <= 16'h0027;
                    coeff4 <= 16'h002b;
                    coeff5 <= 16'h002b;
                    coeff6 <= 16'h0027;
                    coeff7 <= 16'h001e;
                end
                2'b10: begin
                    coeff0 <= 16'h0004;
                    coeff1 <= 16'h000a;
                    coeff2 <= 16'h0012;
                    coeff3 <= 16'h001a;
                    coeff4 <= 16'h001e;
                    coeff5 <= 16'h001e;
                    coeff6 <= 16'h001a;
                    coeff7 <= 16'h0012;
                end
                2'b11: begin
                    coeff0 <= 16'h0001;
                    coeff1 <= 16'h0003;
                    coeff2 <= 16'h0006;
                    coeff3 <= 16'h0009;
                    coeff4 <= 16'h000b;
                    coeff5 <= 16'h000b;
                    coeff6 <= 16'h0009;
                    coeff7 <= 16'h0006;
                end
                default: begin
                    coeff0 <= 16'h000a;
                    coeff1 <= 16'h0013;
                    coeff2 <= 16'h0022;
                    coeff3 <= 16'h0031;
                    coeff4 <= 16'h003a;
                    coeff5 <= 16'h003a;
                    coeff6 <= 16'h0031;
                    coeff7 <= 16'h0022;
                end
            endcase

            shift_reg0 <= {shift_reg7, data_in};
            shift_reg1 <= {shift_reg0, data_in};
            shift_reg2 <= {shift_reg1, data_in};
            shift_reg3 <= {shift_reg2, data_in};
            shift_reg4 <= {shift_reg3, data_in};
            shift_reg5 <= {shift_reg4, data_in};
            shift_reg6 <= {shift_reg5, data_in};
            shift_reg7 <= {shift_reg6, data_in};

            data_out <= coeff7 * shift_reg7 + coeff6 * shift_reg6 + coeff5 * shift_reg5 + coeff4 * shift_reg4 + coeff3 * shift_reg3 + coeff2 * shift_reg2 + coeff1 * shift_reg1 + coeff0 * shift_reg0;
        end
    end
endmodule