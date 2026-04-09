module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH * ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Combine the two always_comb blocks into one to eliminate temporary arrays.
    // This reduces the number of wires significantly (target ≥66% reduction).
    always_comb begin
        for (int j = 0; j < DATA_WIDTH; j++) begin
            int row, col, r, c;
            row = j / 16;
            col = j % 16;
            if (j < 128) begin
                // For j < 128: r = (j - 2*(j/16)) mod 16  and c = (j - (j/16)) mod 16
                // With j = 16*row + col, this becomes:
                r = (14 * row + col) % 16;
                c = (15 * row + col) % 16;
            end else begin
                // For j ≥ 128: r = (j - 2*(j/16) - 1) mod 16  and c = (j - (j/16) - 1) mod 16
                r = ((14 * row + col) - 1) % 16;
                c = ((15 * row + col) - 1) % 16;
            end
            out_data[j] = in_data[r * 16 + c];
        end
    end

endmodule