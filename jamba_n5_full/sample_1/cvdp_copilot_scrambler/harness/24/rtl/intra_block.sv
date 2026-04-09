module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    logic [7:0] output_index[256];

    // Pre‑compute the output index for every possible data value
    initial begin
        for (int j = 0; j < 256; j++) begin
            output_index[j] = r_prime[j] * 16 + c_prime[j];
        end
    end

    always_comb begin
        for (int j = 0; j < 256; j++) begin
            out_data[j]     = in_data[output_index[j]];
        end
    end

endmodule
