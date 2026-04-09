module swizzler #(
    parameter int N = 8
) (
    input clk,
    input reset,
    input [N-1:0] data_in,
    input [N*($clog2(N+1))-1:0] mapping_in,
    input operation_mode,
    input config_in,
    output [N-1:0] data_out,
    output reg error_flag
);
    localparam int M = $clog2(N+1);
    reg [N-1:0] swizzle_reg;
    reg [N-1:0] operation_reg;

    // Pipeline registers
    always_ff @(posedge clk) begin
        if (reset) begin
            swizzle_reg <= '0;
            operation_reg <= '0;
            error_flag <= 0;
        end
        else begin
            swizzle_reg <= data_in & {N{mapping_in[N*M-1:0]}};
            operation_reg <= swizzle_reg;
            error_flag <= 0;
        end
    end

    // Operation mode logic
    always_comb begin
        case (operation_mode)
            3'b000: operation_reg <= swizzle_reg;
            3'b001: operation_reg <= swizzle_reg;
            3'b010: operation_reg <= {N{swizzle_reg[N-1:0]}, swizzle_reg[0:N-2]};
            3'b011: operation_reg <= {swizzle_reg[N-1:0], N{swizzle_reg[0:N-1]}};
            3'b100: operation_reg <= ~swizzle_reg;
            3'b101: operation_reg <= {swizzle_reg[N-1], swizzle_reg[0:N-2], swizzle_reg[N]} & {N{swizzle_reg[N*M-1:0]}};
            3'b110: operation_reg <= {swizzle_reg[N-1:0], swizzle_reg[N]} & {N{swizzle_reg[0:N-1]}};
            3'b111: operation_reg <= swizzle_reg;
            default: operation_reg <= '0;
        endcase
    end

    // Invalid-mapping error detection
    always_comb begin
        int invalid_index;
        for (int i = 0; i < N; i++) begin
            if (operation_reg[i] >= N) begin
                invalid_index = i;
                break;
            end
        end
        if (invalid_index != -1) begin
            swizzle_reg <= '0;
            error_flag <= 1;
        end
    end

    // Final bit reversal
    always_comb begin
        data_out = operation_reg;
        if (config_in) begin
            data_out = {N{data_out[N-1:0]}, data_out[0:N-1]};
        end
    end

endmodule
