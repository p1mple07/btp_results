module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH * ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data, // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    logic [ROW_COL_WIDTH-1:0] r_prime[255];
    logic [ROW_COL_WIDTH-1:0] c_prime[255];

    // Calculate row and column indices in one loop
    always_comb begin
        integer j;
        for (j = 0; j < 256; j++) begin
            if (j < ROW_COL_WIDTH) begin
                r_prime[j] = j / ROW_COL_WIDTH;
                c_prime[j] = j % ROW_COL_WIDTH;
            end else begin
                r_prime[j] = (j - ROW_COL_WIDTH) / ROW_COL_WIDTH;
                c_prime[j] = (j - ROW_COL_WIDTH) % ROW_COL_WIDTH;
            end
        end
    end

    always_comb begin
        integer j;
        for (j = 0; j < 256; j++) begin
            out_data[j] = in_data[r_prime[j] * ROW_COL_WIDTH + c_prime[j]];
        end
    end

endmodule
