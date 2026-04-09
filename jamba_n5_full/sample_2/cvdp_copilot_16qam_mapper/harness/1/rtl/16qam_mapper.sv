module qam16_mapper_interpolated #(
    parameter N = 4,
    parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = 3
)(
    input logic [N*IN_WIDTH-1:0] bits,
    output logic [OUT_WIDTH*2-1:0] I,
    output logic [OUT_WIDTH*2-1:0] Q
);

    // Helper functions
    function static logic [OUT_WIDTH*2-1:0] map_symbol(logic [IN_WIDTH-1:0] sym);
        logic [2:0] msb;
        logic [1:0] lsb;
        assign msb = sym[IN_WIDTH-2 : IN_WIDTH-1];
        assign lsb = sym[IN_WIDTH-3 : IN_WIDTH-4];
        assign I_part = {msb[2:0], lsb[2:0]};
        assign Q_part = {msb[1:0], lsb[1:0]};
        assign mapped_I = I_part[2:0];
        assign mapped_Q = Q_part[2:0];
        assign mapped_I = mapped_I;
        assign mapped_Q = mapped_Q;
    endfunction

    // Process each symbol
    for (integer i = 0; i < N; i++) begin
        logic [IN_WIDTH-1:0] sym;
        assign sym = bits[(i*IN_WIDTH) : (i+1)*IN_WIDTH];
        logic [OUT_WIDTH*2-1:0] mapped_I = map_symbol(sym[0:IN_WIDTH-1]);
        logic [OUT_WIDTH*2-1:0] mapped_Q = map_symbol(sym[IN_WIDTH:2*IN_WIDTH-1]);
        assign I[i*OUT_WIDTH + j*OUT_WIDTH] = mapped_I;
        assign I[i*OUT_WIDTH + j*OUT_WIDTH + 1] = mapped_I + mapped_I;
        assign Q[i*OUT_WIDTH + j*OUT_WIDTH] = mapped_Q;
        assign Q[i*OUT_WIDTH + j*OUT_WIDTH + 1] = mapped_Q + mapped_Q;
    end

endmodule
