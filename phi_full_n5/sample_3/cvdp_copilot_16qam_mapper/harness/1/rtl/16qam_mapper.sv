module qam16_mapper_interpolated #(parameter N = 4, IN_WIDTH = 4, OUT_WIDTH = 3)
(
    input [N*IN_WIDTH-1:0] bits,
    output [(N + N/2)*OUT_WIDTH-1:0] I,
    output [(N + N/2)*OUT_WIDTH-1:0] Q
);

    logic [IN_WIDTH-1:0] MSB, LSB;
    logic [OUT_WIDTH-1:0] I_val, Q_val;

    // Mapping Input Bits
    always_comb begin
        integer i;
        for (i = 0; i < N; i = i + 1) begin
            MSB = bits[(i*IN_WIDTH-1) : (i*IN_WIDTH-2)];
            LSB = bits[(i*IN_WIDTH-1) : (i*IN_WIDTH)];

            case (MSB)
                2'b00: I_val = {1'b-3, 32'h0000};
                2'b01: I_val = {1'b-1, 32'h0001};
                2'b10: I_val = {1'b1, 32'h0002};
                2'b11: I_val = {1'b3, 32'h0003};
                default: I_val = {1'b0, 32'h0000};
            endcase

            case (LSB)
                2'b00: Q_val = {1'b-3, 32'h0000};
                2'b01: Q_val = {1'b-1, 32'h0001};
                2'b10: Q_val = {1'b1, 32'h0002};
                2'b11: Q_val = {1'b3, 32'h0003};
                default: Q_val = {1'b0, 32'h0000};
            endcase

            I <= I_val << (N + N/2 - 1);
            Q <= Q_val << (N + N/2 - 1);
        end
    end

    // Interpolation
    always_comb begin
        integer i;
        for (i = 0; i < N - 1; i = i + 2) begin
            I_val = (I[(i*OUT_WIDTH-1) : (i*OUT_WIDTH)] + I[(i*OUT_WIDTH + OUT_WIDTH-1) : (i*OUT_WIDTH + OUT_WIDTH)]) >> 1;
            Q_val = (Q[(i*OUT_WIDTH-1) : (i*OUT_WIDTH)] + Q[(i*OUT_WIDTH + OUT_WIDTH-1) : (i*OUT_WIDTH + OUT_WIDTH)]) >> 1;

            I[(i*OUT_WIDTH-1) : (i*OUT_WIDTH)] = I_val;
            Q[(i*OUT_WIDTH-1) : (i*OUT_WIDTH)] = Q_val;
        end
    end

endmodule
