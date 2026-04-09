module IntraBlockAreaOpt #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Temporary storage for intermediate calculations
    logic [3:0] r_prime [0:255]; // Row index for each bit
    logic [3:0] c_prime [0:255]; // Column index for each bit

    logic [ROW_COL_WIDTH-1:0] prev_out_data [ROW_COL_WIDTH-1:0];

    always_comb begin
       for(int i = 0; i < 256; i++) begin
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
    int j, k;
    logic [7:0] output_index[256];
    assign output_index = {r_prime[255:224], r_prime[223:192], r_prime[191:160], r_prime[159:128],
                               c_prime[255:224], c_prime[223:192], c_prime[191:160], c_prime[159:128]};
    assign out_data      = in_data[output_index];

endmodule