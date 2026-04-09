module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
    // Operation Mode control: 3-bit value selecting transformation
    // 3'b000: Swizzle Only
    // 3'b001: Passthrough
    // 3'b010: Reverse
    // 3'b011: Swap Halves
    // 3'b100: Bitwise Inversion
    // 3'b101: Circular Left Shift
    // 3'b110: Circular Right Shift
    // 3'b111: Default / Same as Swizzle
    input logic operation_mode
)
(
    input clk,
    input reset,
    // Serial Input data lanes
    input logic [N-1:0] data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input logic [N*$clog2(N+1)-1:0] mapping_in,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input logic config_in,
    // Final output after transformations
    output logic [N-1:0] data_out
);
    localparam int M = $clog2(N+1);
    logic [M-1:0] map_idx [N];
    logic [N-1:0] swizzle_reg;
    logic [N-1:0] operation_reg;
    logic [N-1:0] error_reg;
    logic temp_error_flag = 0;
    genvar j;
    generate
        for (j = 0; j < N; j++) begin : lane_mapping
            assign map_idx[j] = mapping_in[j*M +: M];
        end
    endgenerate

    always_ff @ (posedge clk) begin
        if (reset) begin
            swizzle_reg <= (N-1:0) '0;
            operation_reg <= (N-1:0) '0;
            error_reg <= (N-1:0) '0;
        end
        else begin
            // Process swizzle
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] >= N) begin
                    temp_error_flag = 1;
                end
                else begin
                    if (operation_mode == 3'b000 || operation_mode == 3'b001) begin
                        // Swizzle Only or Passthrough
                        operation_reg[i] = data_in[map_idx[i]];
                    end else if (operation_mode == 3'b010) begin
                        // Reverse
                        operation_reg[i] = data_in[N-1 - map_idx[i]];
                    end else if (operation_mode == 3'b011) begin
                        // Swap Halves
                        operation_reg[i] = (data_in[map_idx[i] >> 1] >> 1) | \
                                          (data_in[map_idx[i] & 1] << (N-1 - (map_idx[i] >> 1)));
                    end else if (operation_mode == 3'b100) begin
                        // Bitwise Inversion
                        operation_reg[i] = ~data_in[map_idx[i]];
                    end else if (operation_mode == 3'b101) begin
                        // Circular Left Shift
                        operation_reg[i] = (data_in[map_idx[i] + 1] << (N-1)) | \
                                          data_in[map_idx[i] & (N-1)];
                    end else if (operation_mode == 3'b110) begin
                        // Circular Right Shift
                        operation_reg[i] = (data_in[map_idx[i] >> 1] >> 1) | \
                                          (data_in[map_idx[i] & 1] << (N-1 - (map_idx[i] >> 1)));
                    end else if (operation_mode == 3'b111) begin
                        // Default / Same as Swizzle
                        operation_reg[i] = data_in[map_idx[i]];
                    end
                end
            end

            // Apply error flag
            if (temp_error_flag) begin
                operation_reg <= (N-1:0) '0;
            end
            error_reg = (error_reg << 1) | temp_error_flag;
        end
    endalways

    // Final bit reversal
    always_ff @ (posedge clk) begin
        if (reset) begin
            data_out <= (N-1:0) '0;
        end
        else begin
            for (int i = 0; i < N; i++) begin
                data_out[i] = operation_reg[N-1 - i];
            end
        end
    endalways