module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
)(
    input  logic         clk,
    input  logic         reset,
    // Serial Input data lanes
    input  logic [N-1:0] data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input  logic [N*$clog2(N+1)-1:0] mapping_in,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input  logic         config_in,
    // Operation mode: selects final transformation (passthrough, reverse, swap halves, invert, circular shifts, etc.)
    input  logic [2:0]   operation_mode,
    // Serial Output data lanes
    output logic [N-1:0] data_out,
    // Error flag: asserted if any mapping index is invalid (>= N)
    output logic         error_flag
);

    // Adjust M to allow detection of an index equal to N
    localparam int M = $clog2(N+1);

    //--------------------------------------------------------------------------
    // Mapping Index Extraction
    //--------------------------------------------------------------------------
    // Create an array of mapping indices from the concatenated mapping_in signal.
    genvar j;
    generate
        for (j = 0; j < N; j++) begin : lane_mapping
            assign map_idx[j] = mapping_in[j*M +: M];
        end
    endgenerate

    // Declare the mapping index array
    logic [M-1:0] map_idx [N];

    //--------------------------------------------------------------------------
    // Swizzle Calculation and Invalid-Mapping Error Detection
    //--------------------------------------------------------------------------
    // temp_swizzled_data: each bit is assigned data_in[map_idx[i]] if valid; 0 if invalid.
    // error_detected is set if any mapping index is >= N.
    logic [N-1:0] temp_swizzled_data;
    logic [N-1:0] processed_swizzle_data;
    logic         error_detected;

    always_comb begin
        error_detected = 1'b0;
        for (int i = 0; i < N; i++) begin
            if (map_idx[i] >= N) begin
                error_detected = 1'b1;
                temp_swizzled_data[i] = 1'b0;
            end
            else begin
                temp_swizzled_data[i] = data_in[ map_idx[i] ];
            end
        end
    end

    // Processed swizzle data: applies immediate reversal if config_in is 0.
    always_comb begin
        if (config_in) begin
            processed_swizzle_data = temp_swizzled_data;
        end
        else begin
            // Reverse the bits: processed_swizzle_data[i] = temp_swizzled_data[N-1-i]
            for (int i = 0; i < N; i++) begin
                processed_swizzle_data[i] = temp_swizzled_data[N-1-i];
            end
        end
    end

    //--------------------------------------------------------------------------
    // Pipeline Registers and Operation Transformation
    //--------------------------------------------------------------------------
    // swizzle_reg: captures the processed_swizzle_data each clock cycle.
    // op_reg_comb: combinational result after applying the selected operation_mode transformation.
    // operation_reg: registered output of the operation stage.
    logic [N-1:0] swizzle_reg;
    logic [N-1:0] op_reg_comb;
    logic [N-1:0] operation_reg;
    logic         error_reg;

    // Combinational block to apply the selected operation_mode transformation on swizzle_reg.
    always_comb begin
        case (operation_mode)
            3'b000, 3'b001: begin
                // Swizzle Only / Passthrough: no change.
                op_reg_comb = swizzle_reg;
            end
            3'b010: begin
                // Reverse: bit reversal of swizzle_reg.
                for (int i = 0; i < N; i++) begin
                    op_reg_comb[i] = swizzle_reg[N-1-i];
                end
            end
            3'b011: begin
                // Swap Halves: lower half becomes upper half and vice versa.
                // (Assumes N is even. For odd N, behavior is undefined.)
                for (int i = 0; i < N/2; i++) begin
                    op_reg_comb[i] = swizzle_reg[N - i - 1];
                end
                for (int i = N/2; i < N; i++) begin
                    op_reg_comb[i] = swizzle_reg[i - N/2];
                end
            end
            3'b100: begin
                // Bitwise Inversion: flip each bit.
                op_reg_comb = ~swizzle_reg;
            end
            3'b101: begin
                // Circular Left Shift: shift left by 1 with MSB wrapping to bit0.
                op_reg_comb = { swizzle_reg[N-2:0], swizzle_reg[N-1] };
            end
            3'b110: begin
                // Circular Right Shift: shift right by 1 with LSB wrapping to bit N-1.
                op_reg_comb = { swizzle_reg[0], swizzle_reg[N-1:1] };
            end
            3'b111: begin
                // Default: same as swizzle.
                op_reg_comb = swizzle_reg;
            end
            default: begin
                op_reg_comb = swizzle_reg;
            end
        endcase
    end

    //--------------------------------------------------------------------------
    // Final Pipeline Stage: Output Registration and Final Bit Reversal
    //--------------------------------------------------------------------------
    // The final stage reindexes bits so that data_out[i] = operation_reg[N-1-i],
    // ensuring the MSB in the output corresponds to the leftmost bit.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            swizzle_reg    <= '0;
            operation_reg  <= '0;
            error_reg      <= 1'b0;
            data_out       <= '0;
        end
        else begin
            swizzle_reg    <= processed_swizzle_data;
            operation_reg  <= op_reg_comb;
            // Final bit reversal stage.
            for (int i = 0; i < N; i++) begin
                data_out[i] <= operation_reg[N-1-i];
            end
            error_reg      <= error_detected;
        end
    end

    assign error_flag = error_reg;

endmodule