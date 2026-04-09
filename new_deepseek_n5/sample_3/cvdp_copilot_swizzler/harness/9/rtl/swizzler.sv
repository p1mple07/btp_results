module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8,
    // Operation Mode control
    parameter int operation_mode = 0
)(
    input clk,
    input reset,
    // Serial Input data lanes
    input  logic [N-1:0]                 data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input  logic [N*$clog2(N+1)-1:0]     mapping_in,
    // Operation Mode control signals
    input  logic operation_mode,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input  logic                         config_in,
    // Serial Output data lanes
    output logic [N-1:0]                 data_out
);
    localparam int M = $clog2(N+1);
    logic [M-1:0] map_idx [N];
    logic [N-1:0] swizzle_reg;
    logic [N-1:0] operation_reg;
    logic error_flag;
    logic error_reg;
    reg [N-1:0] temp_swizzled_data;
    reg [N-1:0] processed_swizzle_data;
    reg [N-1:0] operation_reg_data;
    generate
        for (j = 0; j < N; j++) begin : lane_mapping
            assign map_idx[j] = mapping_in[j*M +: M];
        end
    endgenerate

    always_ff @ (posedge clk) begin
        if (reset) begin
            swizzle_reg <= 0;
            operation_reg <= 0;
            error_flag <= 0;
        end
        else begin
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] >= N) begin
                    temp_error_flag = 1;
                end
                else begin
                    if (config_in) begin
                        processed_swizzle_data[i] <= temp_swizzled_data[i];
                    end
                    else begin
                        processed_swizzle_data[i] <= temp_swizzled_data[N-1-i];
                    end
                end
            end
            if (temp_error_flag) begin
                error_flag = 1;
            end
            // Apply operation mode
            case (operation_mode)
                3'b000: operation_reg_data = swizzle_reg;
                3'b001: operation_reg_data = swizzle_reg;
                3'b010: operation_reg_data = ~swizzle_reg;
                3'b011: operation_reg_data = rotate_left(swizzle_reg);
                3'b100: operation_reg_data = rotate_right(swizzle_reg);
                3'b101: operation_reg_data = swap_halves(swizzle_reg);
                3'b110: operation_reg_data = swizzle_reg;
                default: operation_reg_data = swizzle_reg;
            endcase
            operation_reg <= operation_reg_data;
            // Final bit reversal
            data_out <= [operation_reg[N-1:0] - 1:0];
        end
    end
endmodule