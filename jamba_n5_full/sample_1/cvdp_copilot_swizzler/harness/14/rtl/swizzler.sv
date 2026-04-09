
localparam int M = $clog2(N+1);
logic [M-1:0] map_idx [N];
genvar j;
generate
    for (j = 0; j < N; j++) begin
        assign map_idx[j] = mapping_in[j*M + 1 +: M];
    end
endgenerate
