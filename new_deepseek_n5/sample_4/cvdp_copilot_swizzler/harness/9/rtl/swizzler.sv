module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8,
    // Operation Mode control: 3-bit value selecting transformation
    parameter int operation_mode = 0
)(
    input clk,
    input reset,
    // Serial Input data lanes
    input  logic [N-1:0]                 data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input  logic [N*$clog2(N+1)-1:0]     mapping_in,
    // Operation Mode control: 3-bit value selecting transformation
    input  logic [2:0]                   operation_mode,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input  logic                         config_in,
    // Serial Output data lanes
    output logic [N-1:0]                 data_out
);
    localparam int M = $clog2(N+1);
    logic [M-1:0] map_idx [N];
    reg [M-1:0] temp_swizzled_data [N];
    reg [M-1:0] processed_swizzle_data [N];
    reg operation_reg [N-1:0];
    reg error_reg;
    reg temp_error_flag = 0;
    reg [N-1:0] swizzle_reg;
    
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
            // Assign temp_swizzled_data
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] >= 0 && map_idx[i] < N) begin
                    if (config_in) begin
                        processed_swizzle_data[i] = temp_swizzled_data[i];
                    else begin
                        processed_swizzle_data[i] = temp_swizzled_data[N-1-i];
                    end
                else begin
                    processed_swizzle_data[i] = 0;
                end
            end

            // Apply operation_mode
            case (operation_mode)
                3'b000: // Swizzle Only
                    operation_reg = processed_swizzle_data;
                    swizzle_reg = processed_swizzle_data;
                    break;
                3'b001: // Passthrough
                    operation_reg = processed_swizzle_data;
                    swizzle_reg = temp_swizzled_data;
                    break;
                3'b010: // Reverse
                    operation_reg = {
                        processed_swizzle_data[N-1],
                        processed_swizzle_data[N-2],
                        processed_swizzle_data[N-3],
                        processed_swizzle_data[N-4],
                        processed_swizzle_data[N-5],
                        processed_swizzle_data[N-6],
                        processed_swizzle_data[N-7]
                    };
                    swizzle_reg = temp_swizzled_data;
                    break;
                3'b011: // Swap Halves
                    operation_reg = {
                        processed_swizzle_data[N/2-1:0],
                        processed_swizzle_data[N-1:N/2]
                    };
                    swizzle_reg = temp_swizzled_data;
                    break;
                3'b100: // Bitwise Inversion
                    operation_reg = ~processed_swizzle_data;
                    swizzle_reg = temp_swizzled_data;
                    break;
                3'b101: // Circular Left Shift
                    operation_reg = {
                        processed_swizzle_data[N-1],
                        processed_swizzle_data[0: N-2]
                    };
                    swizzle_reg = temp_swizzled_data;
                    break;
                3'b110: // Circular Right Shift
                    operation_reg = {
                        processed_swizzle_data[N-2: N-1],
                        processed_swizzle_data[0: N-3]
                    };
                    swizzle_reg = temp_swizzled_data;
                    break;
                3'b111: // Default / Same as Swizzle
                    operation_reg = processed_swizzle_data;
                    swizzle_reg = processed_swizzle_data;
                    break;
            endcase

            // Final bit reversal
            for (int i = 0; i < N; i++) begin
                data_out[i] = operation_reg[N-1-i];
            end
        end
    endalways

    // Error detection
    always @ (posedge clk) begin
        temp_error_flag = 0;
        for (int i = 0; i < N; i++) begin
            if (map_idx[i] >= N) begin
                temp_error_flag = 1;
                break;
            end
        end
    end
    // Propagate error flag on next clock
    always @ (posedge clk or negedge reset) begin
        error_flag <= temp_error_flag;
    end
endmodule