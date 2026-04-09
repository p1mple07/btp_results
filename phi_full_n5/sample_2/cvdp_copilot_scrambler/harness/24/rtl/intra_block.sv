module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Optimized temporary storage using concatenation
    logic [ROW_COL_WIDTH-1:0] r_prime [0:255]; // Row index for each bit
    logic [ROW_COL_WIDTH-1:0] c_prime [0:255]; // Column index for each bit

    // Optimized index calculation
    logic [ROW_COL_WIDTH-1:0] output_index[256];

    always_comb begin
       // Calculate row and column index in a single loop
       for (int i = 0; i < 256; i++) begin
           if (i < ROW_COL_WIDTH) begin
               r_prime[i] = i % ROW_COL_WIDTH;
               c_prime[i] = i / ROW_COL_WIDTH;
           end else begin
               r_prime[i] = (i - ROW_COL_WIDTH) % ROW_COL_WIDTH;
               c_prime[i] = (i - ROW_COL_WIDTH) / ROW_COL_WIDTH;
           end
           output_index[i] = {r_prime[i], c_prime[i]};
       end

       // Rearrange bits using concatenation
       for (int i = 0; i < 256; i++) begin
           out_data[i] = in_data[output_index[i]];
       end
    end
endmodule
