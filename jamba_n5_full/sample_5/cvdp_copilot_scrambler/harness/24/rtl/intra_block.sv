module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    logic [3:0] r_prime [0:255];
    logic [3:0] c_prime [0:255];
    logic [7:0] output_index[256];

    // Pre‑compute the row‑prefixed and column‑prefixed indices
    initial begin
        for (int i = 0; i < 256; i++) begin
            if (i < 128) begin
                r_prime[i] = (i - 2 * (i / 16)) % 16;
                c_prime[i] = (i -     (i / 16)) % 16;
            end
            else begin
                r_prime[i] = (i - 2 * (i / 16) - 1) % 16;
                c_prime[i] = (i - (i / 16) - 1) % 16;
            end
        end
    end

    // Build the output index mapping
    for (int j = 0; j < 256; j++) begin
        output_index[j] = r_prime[j] * 16 + c_prime[j];
    end

    // Reorder the data
    assign out_data = in_data[output_index[0]];

endmodule
