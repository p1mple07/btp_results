module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Optimized temporary storage for intermediate calculations
    logic [ROW_COL_WIDTH-1:0] r_prime[ROW_COL_WIDTH/2-1:0],
                        c_prime[ROW_COL_WIDTH/2-1:0];

    // Directly assign output index based on row and column mapping
    always_comb begin
       for (int i = 0; i < ROW_COL_WIDTH; i++) begin
         if (i < ROW_COL_WIDTH / 2) begin
            r_prime[i] = i;
            c_prime[i] = ROW_COL_WIDTH - 1 - i;
         end else begin
            r_prime[i] = ROW_COL_WIDTH - 1 - i;
            c_prime[i] = i;
         end
       end

       for (int i = 0; i < DATA_WIDTH; i++) begin
         out_data[i] = in_data[(r_prime[i] * ROW_COL_WIDTH + c_prime[i])];
       end
    end
endmodule
