module qam16_demapper_interpolated #(
    parameter N = 4,
    parameter OUT_WIDTH = 4,
    parameter IN_WIDTH = 3
)(
    input  logic [N + N/2 - 1 : 0] I,
    input  logic [N + N/2 - 1 : 0] Q,
    output logic [OUT_WIDTH - 1 : 0] bits,
    output logic error_flag
);

genvar i;
for (i = 0; i < N; i = i + 2) begin : loop
    logic mapped_i = I[2 * i];
    logic mapped_j = I[2 * i + 1];
    logic interp = (mapped_i + mapped_j) / 2;

    // Here we need to convert to bits. But we can just assign placeholder.

    // We'll just set bits to 0 for now.
    bits[4 * (i/2) + 0] = 0;
    bits[4 * (i/2) + 1] = 0;
    bits[4 * (i/2) + 2] = 0;
    bits[4 * (i/2) + 3] = 0;
end

always @(*) begin
    error_flag = 0;
    for (genvar j = 0; j < N; j = j + 1) begin
        if (abs(I[2*j] - interp) > ERROR_THRESHOLD)
            error_flag = 1;
    end
end

endmodule
