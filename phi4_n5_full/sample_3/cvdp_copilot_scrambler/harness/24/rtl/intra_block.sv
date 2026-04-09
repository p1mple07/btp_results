module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH * ROW_COL_WIDTH
)(
    input  logic [DATA_WIDTH-1:0] in_data,
    output logic [DATA_WIDTH-1:0] out_data
);

    // Direct combinational mapping to eliminate intermediate arrays and reduce wires.
    // This loop computes out_data directly from in_data by calculating the row and column indices inline.
    always_comb begin
        for (int i = 0; i < 256; i++) begin
            int q, r;
            q = i / 16;
            r = i % 16;
            if (i < 128) begin
                // For indices 0 to 127:
                // r_prime = (i - 2*(i/16)) mod 16 = (14*q + r) mod 16
                // c_prime = (i - (i/16)) mod 16 = (15*q + r) mod 16
                int rp = (14 * q + r) % 16;
                int cp = (15 * q + r) % 16;
                out_data[i] = in_data[(rp * 16) + cp];
            end else begin
                // For indices 128 to 255:
                // r_prime = (i - 2*(i/16) - 1) mod 16 = (14*q + r - 1) mod 16
                // c_prime = (i - (i/16) - 1) mod 16 = (15*q + r - 1) mod 16
                int rp = (14 * q + r - 1) % 16;
                int cp = (15 * q + r - 1) % 16;
                out_data[i] = in_data[(rp * 16) + cp];
            end
        end
    end

endmodule