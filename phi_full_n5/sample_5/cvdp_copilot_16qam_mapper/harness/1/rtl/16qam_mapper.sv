module qam16_mapper_interpolated #(parameter N = 4, parameter IN_WIDTH = 4, parameter OUT_WIDTH = 3)
(
    input [N*IN_WIDTH-1:0] bits,
    output reg signed [(N + N/2)*OUT_WIDTH-1:0] I,
    output reg signed [(N + N/2)*OUT_WIDTH-1:0] Q
);

    integer i, j;

    // Mapping Input Bits
    always_comb begin
        for (i = 0; i < N; i = i + 1) begin
            unsigned idx = i * IN_WIDTH;
            signed map_I = (bits[idx+IN_WIDTH-1] & '10) - (bits[idx+IN_WIDTH-2] & '10) - 3;
            signed map_Q = (bits[idx] & '10) - (bits[idx+1] & '10) - 3;

            I[(i + N/2)*OUT_WIDTH-1:N/2*OUT_WIDTH] = map_I;
            Q[(i + N/2)*OUT_WIDTH-1:N/2*OUT_WIDTH] = map_Q;
        end
    end

    // Interpolation
    always_comb begin
        for (j = 1; j < N; j = j + 2) begin
            I[(j + N/2)*OUT_WIDTH-1:N/2*OUT_WIDTH] = (I[j*OUT_WIDTH-1:j*OUT_WIDTH] + I[(j-1)*OUT_WIDTH-1:(j-1)*OUT_WIDTH]) / 2;
            Q[(j + N/2)*OUT_WIDTH-1:N/2*OUT_WIDTH] = (Q[j*OUT_WIDTH-1:j*OUT_WIDTH] + Q[(j-1)*OUT_WIDTH-1:(j-1)*OUT_WIDTH]) / 2;
        end
    end

endmodule
