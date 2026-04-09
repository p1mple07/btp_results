module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,
    output logic [DATA_WIDTH-1:0] out_data
);

    // Temporary storage for intermediate calculations
    logic [3:0] r_prime [0:255];
    logic [3:0] c_prime [0:255];

    logic [ROW_COL_WIDTH-1:0] prev_out_data [ROW_COL_WIDTH-1:0];

    always_comb begin
        for(int i = 0; i < 256; i++) begin
            if (i < 128) begin
                r_prime[i] = (i >> 4) & 0xF;
                c_prime[i] = (i >> 4) & 0xF;
            else begin
                r_prime[i] = (i >> 4) & 0xF;
                c_prime[i] = (i >> 4) & 0xF;
            end
        end
    end
    int j, k;
    logic [7:0] output_index[256];
    always_comb begin
        for (j = 0; j < 256; j++) begin
            output_index[j] = (r_prime[j] << 4) | c_prime[j];
            out_data[j]     = in_data[output_index[j]];
        end
    end
endmodule