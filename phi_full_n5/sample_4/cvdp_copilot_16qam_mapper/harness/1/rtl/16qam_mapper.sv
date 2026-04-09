module qam16_mapper_interpolated #(parameter N = 4, IN_WIDTH = 4, OUT_WIDTH = 3)
(
    input [N*IN_WIDTH-1:0] bits,
    output [(N + N/2)*OUT_WIDTH-1:0] I,
    output [(N + N/2)*OUT_WIDTH-1:0] Q
);

    // Local variables for mapping and interpolation
    logic [IN_WIDTH-1:0] MSB, LSB;
    logic [OUT_WIDTH-1:0] mapped_I, mapped_Q, interpolated_I, interpolated_Q;

    // Mapping input bits
    always_comb begin
        for (int i = 0; i < N; i = i + 1) begin
            MSB = bits[(i*IN_WIDTH-1):(i*IN_WIDTH)];
            LSB = bits[(i*IN_WIDTH):(i*IN_WIDTH-1)];

            // Map MSB to I
            case (MSB)
                2'b00: mapped_I = 3'b000;
                2'b01: mapped_I = 3'b001;
                2'b10: mapped_I = 3'b010;
                2'b11: mapped_I = 3'b011;
                default: mapped_I = 3'bxxxx;
            endcase

            // Map LSB to Q
            case (LSB)
                2'b00: mapped_Q = 3'b000;
                2'b01: mapped_Q = 3'b001;
                2'b10: mapped_Q = 3'b010;
                2'b11: mapped_Q = 3'b011;
                default: mapped_Q = 3'bxxxx;
            endcase
        end
    end

    // Interpolation
    always_comb begin
        int j = 0;
        for (int i = 0; i < N-1; i = i + 1) begin
            interpolated_I = (mapped_I[j*OUT_WIDTH] + mapped_I[(j+1)*OUT_WIDTH-1]) / 2;
            interpolated_Q = (mapped_Q[j*OUT_WIDTH] + mapped_Q[(j+1)*OUT_WIDTH-1]) / 2;

            // Concatenate mapped and interpolated values
            I[(i*OUT_WIDTH+j*2*OUT_WIDTH):(i*OUT_WIDTH+j*2*OUT_WIDTH+OUT_WIDTH-1)] = mapped_I[j*OUT_WIDTH:j*OUT_WIDTH+OUT_WIDTH-1];
            I[(i*OUT_WIDTH+j*2*OUT_WIDTH+OUT_WIDTH):(i*OUT_WIDTH+j*2*OUT_WIDTH+2*OUT_WIDTH-1)] = interpolated_I;
            I[(i*OUT_WIDTH+j*2*OUT_WIDTH+2*OUT_WIDTH):(i*OUT_WIDTH+j*2*OUT_WIDTH+3*OUT_WIDTH-1)] = mapped_I[(j+1)*OUT_WIDTH-OUT_WIDTH+1:OUT_WIDTH-1];

            Q[(i*OUT_WIDTH+j*2*OUT_WIDTH+OUT_WIDTH):(i*OUT_WIDTH+j*2*OUT_WIDTH+2*OUT_WIDTH-1)] = mapped_Q[j*OUT_WIDTH:j*OUT_WIDTH+OUT_WIDTH-1];
            Q[(i*OUT_WIDTH+j*2*OUT_WIDTH+2*OUT_WIDTH):(i*OUT_WIDTH+j*2*OUT_WIDTH+3*OUT_WIDTH-1)] = interpolated_Q;

            j = j + 1;
        end
    end

endmodule
