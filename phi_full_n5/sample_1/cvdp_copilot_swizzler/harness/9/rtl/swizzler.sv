module swizzler #(
    parameter int N = 8
) (
    input clk,
    input reset,
    input [N-1:0] data_in,
    input [N*($clog2(N+1))-1:0] mapping_in,
    input operation_mode,
    input config_in,
    output logic [N-1:0] data_out,
    output logic error_flag
);
    // Parameter M = $clog2(N) for valid mapping indices
    localparam int M = $clog2(N);
    localparam int M_plus_1 = M + 1; // M + 1 for invalid mapping index detection

    // Swizzle register
    logic [N-1:0] swizzle_reg;
    // Operation control register
    logic [N-1:0] operation_reg;
    // Error flag register
    logic error_reg;

    // Pipeline registers
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            swizzle_reg <= '0;
            operation_reg <= '0;
            error_reg <= 0;
        } else begin
            swizzle_reg <= data_in;
            operation_reg <= '0;
            error_reg <= 0;
        end
    end

    // Swizzle calculation with invalid mapping index detection
    always_comb begin
        error_reg = 0;
        for (int i = 0; i < N; i++) begin
            case (mapping_in[i*M_plus_1 +: M])
                M_plus_1'b0: begin
                    swizzle_reg[i] <= data_in[mapping_in[i*M_plus_1 +: M]];
                end
                default: begin
                    swizzle_reg[i] <= '0;
                    error_reg = 1;
                end
            endcase
        end
    end

    // Operation mode selection
    always_comb begin
        case (operation_mode)
            3'b000: operation_reg <= swizzle_reg;
            3'b001: operation_reg <= swizzle_reg;
            3'b010: operation_reg <= {swizzle_reg[N-1:0], swizzle_reg[0:N-2]};
            3'b011: operation_reg <= {swizzle_reg[N-1:1], swizzle_reg[0:N-2]};
            3'b100: operation_reg <= ~swizzle_reg;
            3'b101: operation_reg <= {swizzle_reg[N-2:0], swizzle_reg[N-1]};
            3'b110: operation_reg <= {swizzle_reg[N-1:0], swizzle_reg[N-2:1]};
            3'b111: operation_reg <= swizzle_reg;
        endcase
    end

    // Final bit reversal
    assign data_out = {operation_reg[N-1:0], operation_reg[N-2:1]};

    // Error handling
    assign error_flag = error_reg;

    // Swizzle with operation control and error handling
    always_ff @(posedge clk) begin
        if (reset) begin
            data_out <= '0;
        end else begin
            if (error_flag) begin
                data_out <= '0;
            end else begin
                case (config_in)
                    1'b1: data_out <= operation_reg;
                    1'b0: data_out <= {operation_reg[N-1:0], operation_reg[N-2:1]};
                    default: data_out <= operation_reg;
                endcase
            end
        end
    end
endmodule
