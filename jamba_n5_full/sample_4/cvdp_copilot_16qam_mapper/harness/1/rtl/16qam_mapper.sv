module qam16_mapper_interpolated (
    input logic [N*IN_WIDTH-1:0] bits,
    output logic [ (N + N/2) * OUT_WIDTH - 1 : 0 ] I,
    output logic [ (N + N/2) * OUT_WIDTH - 1 : 0 ] Q
);

    localparam N = $unsigned(N);
    localparam IN_WIDTH = $unsigned(IN_WIDTH);
    localparam OUT_WIDTH = $unsigned(OUT_WIDTH);

    localtype int2be : type (logic [OUT_WIDTH-1:0]);

    generate
        for (int i = 0; i < N; i++) begin : sym
            logic [IN_WIDTH-1:0] sym_bits = bits[i*IN_WIDTH + 3 downto i*IN_WIDTH];
            int2be i_val = {
                sym_bits[IN_WIDTH-2 downto IN_WIDTH-1] ? -3 : 3,
                sym_bits[IN_WIDTH-1] ? 1 : 3
            };
            int2be q_val = {
                sym_bits[1 downto 0] ? -1 : 1,
                sym_bits[IN_WIDTH-2 downto 1] ? 3 : 1
            };
            assign I[i*OUT_WIDTH + j] = i_val[OUT_WIDTH-1];
            assign Q[i*OUT_WIDTH + j] = q_val[OUT_WIDTH-1];
        end
    endgenerate

    generate
        for (int i = 0; i < N/2; i++) begin : interp
            int2be i_int = (i_val[OUT_WIDTH-1] + q_val[OUT_WIDTH-1]) / 2;
            int2be q_int = (i_val[OUT_WIDTH-1] + q_val[OUT_WIDTH-1]) / 2;
            assign I[i*(N+N/2)*OUT_WIDTH + i*OUT_WIDTH] = i_int[OUT_WIDTH-1];
            assign I[i*(N+N/2)*OUT_WIDTH + i*OUT_WIDTH + 1] = i_int[OUT_WIDTH-1];
            assign Q[i*(N+N/2)*OUT_WIDTH + i*OUT_WIDTH] = q_int[OUT_WIDTH-1];
            assign Q[i*(N+N/2)*OUT_WIDTH + i*OUT_WIDTH + 1] = q_int[OUT_WIDTH-1];
        end
    endgenerate

endmodule
