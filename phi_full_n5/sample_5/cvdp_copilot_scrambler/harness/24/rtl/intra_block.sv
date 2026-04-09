module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data, // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Optimized temporary storage using packed storage and single loop
    logic [ROW_COL_WIDTH-1:0] packed_r_prime [256-1:0];
    logic [ROW_COL_WIDTH-1:0] packed_c_prime [256-1:0];

    always_comb begin
        for (int i = 0; i < 256; i++) begin
            if (i < 128) begin
                packed_r_prime[i] = (i - 2 * (i / 16)) % 16;
                packed_c_prime[i] = (i -     (i / 16)) % 16;
            end
            else begin
                packed_r_prime[i] = (i - 2 * (i / 16) - 1) % 16;
                packed_c_prime[i] = (i - (i / 16) - 1) % 16;
            end
        end

        // Optimized index calculation
        logic [ROW_COL_WIDTH-1:0] optimized_index[256];
        always_comb begin
            for (int i = 0; i < 256; i++) begin
                optimized_index[i] = packed_r_prime[i] + (packed_c_prime[i] << 4);
            end

            for (int i = 0; i < 256; i++) begin
                out_data[i] = in_data[optimized_index[i]];
            end
        end
    end
endmodule
