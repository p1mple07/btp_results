module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
)(
    input clk,
    input reset,
    // Serial Input data lanes
    input  logic [N-1:0]                 data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input  logic [N*$clog2(N+1)-1:0]       mapping_in,
    // Operation Mode control
    input logic operation_mode,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input logic config_in,
    // Serial Output data lanes
    output logic [N-1:0]                 data_out
);
    localparam int M = $clog2(N);
    logic [M-1:0] map_idx [N];
    logic [N-1:0] swizzle_reg;
    logic [N-1:0] operation_reg;
    logic error_reg [1:0]; // To hold error_flag and possibly others
    logic temp_error_flag;
    genvar j;
    generate
        for (j = 0; j < N; j++) begin : lane_mapping
            assign map_idx[j] = mapping_in[j*M +: M];
        end
    endgenerate

    always_ff @ (posedge clk) begin
        if (reset) begin
            swizzle_reg <= 0;
            operation_reg <= 0;
            error_reg <= 0;
        end
        else begin
            // Process mapping and detect errors
            temp_error_flag = 0;
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] >= N) begin
                    temp_error_flag = 1;
                end
                if (config_in) begin
                    swizzle_reg[i] <= data_in[map_idx[i]];
                end else begin
                    swizzle_reg[i] <= data_in[N-1 - map_idx[i]];
                end
            end
            // Apply operation mode
            case (operation_mode)
                3'b000: operation_reg = swizzle_reg;
                3'b001: operation_reg = swizzle_reg;
                3'b010: begin
                    // Reverse bits
                    operation_reg = ~swizzle_reg;
                    operation_reg = (operation_reg << 1) | (swizzle_reg >> 1);
                end
                3'b011: begin
                    // Swap halves
                    logic [M-1:0] top_half = swizzle_reg[0:M-1];
                    logic [M-1:0] bottom_half = swizzle_reg[N/M:M+N-1];
                    operation_reg = (bottom_half << M) | top_half;
                end
                3'b100: begin
                    // Bitwise inversion
                    operation_reg = ~swizzle_reg;
                end
                3'b101: begin
                    // Circular left shift
                    operation_reg = (swizzle_reg << 1) | (swizzle_reg >> (N-1));
                end
                3'b110: begin
                    // Circular right shift
                    operation_reg = (swizzle_reg >> 1) | (swizzle_reg << (N-1));
                end
                default: operation_reg = swizzle_reg;
            endcase
            // Final bit reversal
            for (int i = 0; i < N; i++) begin
                data_out[i] = operation_reg[N-1 - i];
            end
            // Error handling
            if (temp_error_flag) begin
                error_reg <= 1;
            end else begin
                error_reg <= 0;
            end
        end
    end
endmodule