module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH    = ROW_COL_WIDTH * ROW_COL_WIDTH
)(
    input  logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Optimized combinational logic:
    // Removed intermediate arrays (r_prime, c_prime, output_index, prev_out_data)
    // and merged the two always_comb blocks into one.
    // This reduces the number of wires/signals used in the combinational path.
    //
    // Note: The mapping function is computed on-the-fly for each bit.
    // For indices i < DATA_WIDTH/2, we use:
    //    r = (i - 2*(i/ROW_COL_WIDTH)) % ROW_COL_WIDTH
    //    c = (i - (i/ROW_COL_WIDTH)) % ROW_COL_WIDTH
    // For indices i >= DATA_WIDTH/2, we use:
    //    r = (i - 2*(i/ROW_COL_WIDTH) - 1) % ROW_COL_WIDTH
    //    c = (i - (i/ROW_COL_WIDTH) - 1) % ROW_COL_WIDTH
    //
    // The new index is computed as: new_index = r * ROW_COL_WIDTH + c.
    // The output bit is then taken from in_data[new_index].

    always_comb begin
        for (int i = 0; i < DATA_WIDTH; i++) begin
            if (i < DATA_WIDTH/2) begin
                int r = (i - 2*(i/ROW_COL_WIDTH)) % ROW_COL_WIDTH;
                int c = (i - (i/ROW_COL_WIDTH)) % ROW_COL_WIDTH;
                out_data[i] = in_data[r * ROW_COL_WIDTH + c];
            end else begin
                int r = (i - 2*(i/ROW_COL_WIDTH) - 1) % ROW_COL_WIDTH;
                int c = (i - (i/ROW_COL_WIDTH) - 1) % ROW_COL_WIDTH;
                out_data[i] = in_data[r * ROW_COL_WIDTH + c];
            end
        end
    end

endmodule