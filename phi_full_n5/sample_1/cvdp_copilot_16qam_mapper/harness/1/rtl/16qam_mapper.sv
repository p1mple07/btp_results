module qam16_mapper_interpolated #(parameter N = 4, IN_WIDTH = 4, OUT_WIDTH = 3)
(
    input  logic [N*IN_WIDTH-1:0] bits,
    output logic [(N + N/2)*OUT_WIDTH-1:0] I,
    output logic [(N + N/2)*OUT_WIDTH-1:0] Q
);

    logic [IN_WIDTH-1:0] MSB, LSB;
    logic [OUT_WIDTH-1:0] interpolated_I, interpolated_Q;

    // Mapping input bits
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : mapping_loop
            MSB = bits[(i*IN_WIDTH-1) : (i*IN_WIDTH-2)];
            LSB = bits[(i*IN_WIDTH-1) : (i*IN_WIDTH)];

            // Map MSB to I
            case (MSB)
                2'b00: I[(i*OUT_WIDTH-1) +: OUT_WIDTH] = -3'd3;
                2'b01: I[(i*OUT_WIDTH-1) +: OUT_WIDTH] = -1'd1;
                2'b10: I[(i*OUT_WIDTH-1) +: OUT_WIDTH] = 1'd1;
                2'b11: I[(i*OUT_WIDTH-1) +: OUT_WIDTH] = 3'd3;
                default: I[(i*OUT_WIDTH-1) +: OUT_WIDTH] = 0;
            endcase

            // Map LSB to Q
            case (LSB)
                2'b00: Q[(i*OUT_WIDTH-1) +: OUT_WIDTH] = -3'd3;
                2'b01: Q[(i*OUT_WIDTH-1) +: OUT_WIDTH] = -1'd1;
                2'b10: Q[(i*OUT_WIDTH-1) +: OUT_WIDTH] = 1'd1;
                2'b11: Q[(i*OUT_WIDTH-1) +: OUT_WIDTH] = 3'd3;
                default: Q[(i*OUT_WIDTH-1) +: OUT_WIDTH] = 0;
            endcase
        end
    endgenerate

    // Interpolation
    genvar j;
    generate
        for (j = 0; j < N-1; j = j + 1) begin : interpolation_loop
            interpolated_I = (I[(j*OUT_WIDTH-1) +: OUT_WIDTH] + I[(j*OUT_WIDTH) +: OUT_WIDTH]) / 2'b1;
            interpolated_Q = (Q[(j*OUT_WIDTH-1) +: OUT_WIDTH] + Q[(j*OUT_WIDTH) +: OUT_WIDTH]) / 2'b1;

            // Assign interpolated values to output
            I[(j*OUT_WIDTH-1) +: OUT_WIDTH] = interpolated_I;
            Q[(j*OUT_WIDTH-1) +: OUT_WIDTH] = interpolated_Q;
        end
    endgenerate

endmodule
