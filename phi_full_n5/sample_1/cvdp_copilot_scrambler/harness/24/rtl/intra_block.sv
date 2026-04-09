module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Reduced temporary storage by using a single lookup table
    logic [3:0] index_table [0:255];

    always_comb begin
        // Generate the index table for both row and column
        integer i;
        for (i = 0; i < 256; i++) begin
            if (i < 128) begin
                index_table[i] = (i - 2 * (i / 16)) % 16;
            end
            else begin
                index_table[i] = (i - 2 * (i / 16) - 1) % 16;
            end
        end

        // Perform the transformation using the index table
        integer j;
        for (j = 0; j < 256; j++) begin
            out_data[j] = in_data[index_table[j]];
        end
    end
endmodule
