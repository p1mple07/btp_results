module swizzler #(
    parameter int N = 8
) (
    input  logic clk,
    input  logic reset,
    input  logic [N*$clog2(N+1)-1:0] mapping_in,
    input  logic [2:0] operation_mode,
    input  logic config_in,
    input  logic [N-1:0] data_in,
    output logic [N-1:0] data_out,
    output logic error_flag
);

    localparam int M = $clog2(N);
    logic [M-1:0] map_idx [N];
    logic [3:0] op_mode;
    reg [N-1:0] swizzle_reg;
    reg [N-1:0] operation_reg;
    reg [N-1:0] error_reg;
    reg [N-1:0] data_out_reg;
    reg error_reg_hold;

    // Reset on async reset
    always_ff @(asynch reset) begin
        swizzle_reg <= 0;
        operation_reg <= 0;
        error_reg <= 0;
        data_out_reg <= 0;
        error_flag <= 1;
    end

    // Generate mapping indices
    assign map_idx = {{N*M} ? {mapping_in[0:M]} : {mapping_in[N*M+0:N*M]}};

    // Wait: mapping_in is N*M bits, we need to map each element to an index. But we can just use the mapping_in as is.

    // Process data_in into swizzle_reg
    always_ff @(posedge clk) begin
        if (reset) begin
            swizzle_reg <= 0;
        end else begin
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] >= 0 && map_idx[i] < N) begin
                    if (config_in) begin
                        swizzle_reg[i] = data_in[map_idx[i]];
                    end else begin
                        swizzle_reg[i] = data_in[N-1-map_idx[i]];
                    end
                end
                else begin
                    swizzle_reg[i] = '0;
                end
            end
        end
    end

    // Check for invalid mapping indices
    assign temp_error_flag = any(map_idx >= N);
    assign error_flag = temp_error_flag;

    // Apply operation mode
    always_comb begin
        case (operation_mode)
            3'b000: {swizzle_reg} <= swizzle_reg;
            3'b001: {swizzle_reg} <= data_in;
            3'b010: {swizzle_reg} <= {data_in[N-1], data_in[N-2], ..., data_in[0]}; // reverse
            3'b011: {swizzle_reg} <= {data_in[N-2], data_in[N-3], ..., data_in[0], data_in[1]}; // swap halves
            3'b100: {swizzle_reg} <= {swizzle_reg[N-1], swizzle_reg[N-2], ..., swizzle_reg[0]};
            3'b101: {swizzle_reg} <= {swizzle_reg[0], swizzle_reg[1], ..., swizzle_reg[N-1]};
            3'b110: {swizzle_reg} <= {swizzle_reg[N-1], swizzle_reg[N-2], ..., swizzle_reg[1]};
            3'b111: {swizzle_reg} <= swizzle_reg;
            default: {swizzle_reg} <= swizzle_reg;
        endcase
    end

    // Final bit reversal
    always_ff @(posedge clk) begin
        if (error_flag) begin
            data_out_reg <= 0;
        end else begin
            data_out_reg <= {N[N-1-i] for i in 0 to N-1};
            data_out <= data_out_reg;
        end
    end

endmodule
