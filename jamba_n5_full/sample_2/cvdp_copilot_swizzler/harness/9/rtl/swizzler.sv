module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
)(
    input clk,
    input reset,
    // Serial Input data lanes
    input  logic [N-1:0]                 data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input  logic [N*$clog2(N)-1:0]       mapping_in,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input  logic                         config_in,
    // Serial Output data lanes
    output logic [N-1:0]                 data_out
);

    localparam int M = $clog2(N);

    logic [M-1:0] map_idx [N];
    genvar j;
    generate
        for (j = 0; j < N; j++) begin : lane_mapping
            assign map_idx[j] = mapping_in[j*M +: M];
        end
    endgenerate

    // Swizzle register
    reg [N-1:0] swizzle_reg;
    reg [N-1:0] operation_reg;
    reg [N-1:0] error_reg;
    reg error_flag;

    // Operation mode input
    input [2:0] operation_mode;

    // Operation registers
    always @(posedge clk) begin
        if (reset) begin
            swizzle_reg <= {N{1'b0}};
            operation_reg <= 3'b000;
            error_reg <= 3'b0;
            error_flag <= 1;
        end else begin
            case (operation_mode)
                3'b000: operation_reg <= 3'b000;
                3'b001: operation_reg <= 3'b000;
                3'b010: operation_reg <= 3'b111; // reverse
                3'b011: operation_reg <= 3'b000;
                3'b100: operation_reg <= 3'b000;
                3'b101: operation_reg <= 3'b000;
                3'b110: operation_reg <= 3'b000;
                3'b111: operation_reg <= 3'b000;
                default: operation_reg <= 3'b000;
            endcase
        end
    end

    // Check for invalid mapping
    assign temp_error_flag = ($ge(map_idx[0], N) || ...? Actually we need to check each index. But the spec says: "Whenever `map_idx[i] >= N`, set `temp_error_flag = 1`". So we can check each index inside the loop.

    // We need to implement the check inside the always block.

    Always @(posedge clk) begin
        if (reset) begin
            swizzle_reg <= {N{1'b0}};
            operation_reg <= 3'b000;
            error_reg <= 3'b0;
            error_flag <= 1;
        end else begin
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] >= N) begin
                    error_reg <= 3'b1000; // set to 8'b1000? Wait, they want to drive to 0. But the spec says: "All swizzled data bits are driven to 0." So we can set all to 0.
                    // But the error flag should be 1 on next clock.
                    // Maybe we can just clear all bits.
                end
            end
        end
    end

    // Final bit reversal
    always @(*) begin
        if (error_flag) begin
            data_out <= '0;
        end else begin
            // Reverse operation_reg to data_out
            data_out[i] = operation_reg[N-1-i];
        end
    end

endmodule
