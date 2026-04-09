module swizzler #(
        parameter int N = 8
        ,
        parameter int M = $clog2(N+1),

        logic [M-1:0] map_idx [N];
        genvar j;
        generate
            for (j = 0; j < N; j++) begin
                map_idx[j] = mapping_in[j*M + 1 : j*M + M];
            end
        endgenerate

        logic [N-1:0] temp_swizzled_data;
        logic [N-1:0] processed_swizzle_data;
        logic         temp_error_flag;
        logic [N/2-1:0] swizzle_reg;
        logic [N/2-1:0] default_swizzle_reg;
        logic [N/2-1:0] swizzle_reg;
        default: operation_reg   <= 1'b0;
        end else begin
            for (int i = 0; i < N; i++) begin
                temp_error_flag = 1'b0;
            end
        end else begin
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] > N) {
                    temp_error_flag = 1'b1;
                }
            end
        end else {
            for (int i = 0; i < N; i++) begin
                if (config_in) begin
                    processed_swizzle_data[i] = temp_swizzled_data[i];
                end else begin
                    processed_swizzle_data[i] = temp_swizzled_data[N - 1 - i];
                end
            end
        }
    endmodule