module swizzler #(
    parameter int N = 8
) (
    input clk,
    input reset,
    input  logic [N-1:0] data_in,
    input  logic [N*$clog2(N+1)-1:0] mapping_in,
    input  logic config_in,
    input  logic [2:0] operation_mode,
    output logic [N-1:0] data_out,
    output logic error_flag
);
    localparam int M = $clog2(N+1);
    logic [M-1:0] map_idx [N];
    logic [N-1:0] swizzle_reg, processed_swizzle_data, operation_reg;
    logic error_reg;

    // Swizzle calculation
    always_comb begin
        for (int i = 0; i < N; i++) begin
            map_idx[i] = mapping_in[i*M +: M];
        end
        swizzle_reg = {N{data_in[map_idx[i]]}};
    end

    // Invalid mapping error detection
    always_comb begin
        error_reg = 0;
        for (int i = 0; i < N; i++) begin
            if (map_idx[i] >= N) begin
                error_reg = 1;
                break;
            end
        end
    end

    // Operation mode logic
    always_comb begin
        if (error_reg) begin
            data_out = {N{0}};
        end else begin
            processed_swizzle_data = swizzle_reg;
            operation_reg = {N{0}};

            case (operation_mode)
                3'b000: operation_reg = swizzle_reg;
                3'b001: operation_reg = swizzle_reg;
                3'b010: operation_reg = {N{swizzle_reg[N-1:0]}, swizzle_reg[0:N-2]};
                3'b011: operation_reg = {swizzle_reg[N-1:0], swizzle_reg[0:N-2]};
                3'b100: operation_reg = ~swizzle_reg;
                3'b101: operation_reg = {swizzle_reg[N-1:1], swizzle_reg[0:N-2]};
                3'b110: operation_reg = {swizzle_reg[N-2:0], swizzle_reg[N-1]};
                3'b111: operation_reg = swizzle_reg;
                default: operation_reg = swizzle_reg;
            endcase

            // Bit reversal for config_in = 1
            if (config_in) begin
                for (int i = 0; i < N; i++) begin
                    data_out[i] = operation_reg[i];
                end
            end else begin
                for (int i = 0; i < N; i++) begin
                    data_out[i] = operation_reg[N-1-i];
                end
            end
        end
    end

    // Pipeline registers
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            swizzle_reg <= {N{0}};
            processed_swizzle_data <= {N{0}};
            operation_reg <= {N{0}};
            error_reg <= 0;
        end else begin
            swizzle_reg <= swizzle_reg;
            processed_swizzle_data <= processed_swizzle_data;
            operation_reg <= operation_reg;
            error_reg <= error_reg;
        end
    end
endmodule
