module hamming_code_receiver #(
    parameter WIDTH = 8
)(
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

reg [3:0] c1, c2, c3;

// Compute the parity checks
c1 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
c3 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

// Detect a single‑bit error
if (c1 == 3'b001 && c2 == 3'b000 && c3 == 3'b000) begin
    data_out[1] = ~data_in[1];
end
else if (c1 == 3'b000 && c2 == 3'b001 && c3 == 3'b000) begin
    data_out[2] = ~data_in[2];
end
else if (c1 == 3'b000 && c2 == 3'b000 && c3 == 3'b001) begin
    data_out[4] = ~data_in[4];
end

// Default: no error, keep the input data
data_out = data_in;

endmodule
