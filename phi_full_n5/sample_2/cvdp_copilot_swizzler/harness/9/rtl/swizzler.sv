module swizzler #(
    parameter int N = 8
)(
    input clk,
    input reset,
    input [N-1:0] data_in,
    input [N*$clog2(N+1)-1:0] mapping_in,
    input operation_mode,
    input config_in,
    output reg [N-1:0] data_out,
    output reg error_flag
);

    localparam int M = $clog2(N+1);
    logic [N-1:0] swizzle_reg, operation_reg;
    logic [M-1:0] map_idx [N];
    logic [M-1:0] temp_swizzled_data [N], temp_error_flag;

    always_ff @(posedge clk) begin
        if (reset) begin
            swizzle_reg <= '0;
            operation_reg <= '0;
            error_flag <= 0;
        end
        else begin
            for (int i = 0; i < N; i++) begin
                if (mapping_in[i*M +: M] >= N) begin
                    temp_error_flag <= 1;
                    swizzle_reg <= '0;
                    operation_reg <= '0;
                end
                else begin
                    map_idx[i] <= mapping_in[i*M +: M];
                    swizzle_reg[i] <= data_in[map_idx[i]];
                end
            end

            swizzle_reg <= swizzle_reg;
            temp_swizzled_data <= swizzle_reg;

            case (operation_mode)
                3'b000:
                    operation_reg <= swizzle_reg;
                3'b001:
                    operation_reg <= swizzle_reg;
                3'b010:
                    for (int i = 0; i < N; i++) begin
                        operation_reg[i] <= ~temp_swizzled_data[N-1-i];
                    end
                3'b011:
                    for (int i = 0; i < N; i++) begin
                        operation_reg[i] <= temp_swizzled_data[N-1-i];
                        operation_reg[N-1-i] <= temp_swizzled_data[i];
                    end
                3'b100:
                    operation_reg <= ~temp_swizzled_data;
                3'b101:
                    operation_reg <= rol(temp_swizzled_data, 1);
                3'b110:
                    operation_reg <= ror(temp_swizzled_data, 1);
                3'b111:
                    operation_reg <= swizzle_reg;
                    temp_swizzled_data <= swizzle_reg;
            endcase

            if (temp_error_flag) begin
                error_flag <= 1;
                data_out <= 0;
            end
            else begin
                if (config_in) begin
                    data_out <= operation_reg;
                end
                else begin
                    data_out <= operation_reg;
                end
            end
        end
    end

endmodule
