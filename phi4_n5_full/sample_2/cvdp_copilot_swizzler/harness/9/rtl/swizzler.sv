module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
)(
    input  logic                   clk,
    input  logic                   reset,
    // Serial Input data lanes
    input  logic [N-1:0]           data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    // M is now defined as $clog2(N+1) to allow detection of an invalid index (N)
    input  logic [N*$clog2(N+1)-1:0] mapping_in,
    // Control signal: 0 - mirror the swizzled data, 1 - pass straight
    input  logic                   config_in,
    // Operation mode: selects final transformation on swizzled data
    input  logic [2:0]             operation_mode,
    // Serial Output data lanes
    output logic [N-1:0]           data_out,
    // Error flag: asserted if any mapping index is invalid (≥ N)
    output logic                   error_flag
);

    // Use M = $clog2(N+1) so that an index equal to N is detectable as invalid.
    localparam int M = $clog2(N+1);

    //-------------------------------------------------------------------------
    // Stage 0: Extract mapping indices from mapping_in
    //-------------------------------------------------------------------------
    logic [M-1:0] map_idx [N];
    genvar j;
    generate
        for (j = 0; j < N; j = j + 1) begin : lane_mapping
            assign map_idx[j] = mapping_in[j*M +: M];
        end
    endgenerate

    //-------------------------------------------------------------------------
    // Stage 1: Error Detection
    // If any mapping index is ≥ N then an error is detected.
    //-------------------------------------------------------------------------
    genvar k;
    wire error_bit [N-1:0];
    generate
        for (k = 0; k < N; k = k + 1) begin : gen_error
            assign error_bit[k] = (map_idx[k] >= N);
        end
    endgenerate
    wire error_detected;
    assign error_detected = |error_bit;

    //-------------------------------------------------------------------------
    // Stage 2: Swizzle Calculation
    // For each lane i, if map_idx[i] is valid (< N) then select data_in[map_idx[i]];
    // Otherwise, drive a 0. If any error is detected, all swizzled bits are forced to 0.
    //-------------------------------------------------------------------------
    wire [N-1:0] temp_swizzled_data;
    generate
        for (k = 0; k < N; k = k + 1) begin : gen_temp_swizzle
            assign temp_swizzled_data[k] = (map_idx[k] < N) ? data_in[map_idx[k]] : 1'b0;
        end
    endgenerate
    wire [N-1:0] swizzle_data;
    assign swizzle_data = (error_detected) ? '0 : temp_swizzled_data;

    //-------------------------------------------------------------------------
    // Stage 3: Processed Swizzle Data (Swizzle + Config Control)
    // If config_in = 1, pass swizzle_data straight.
    // If config_in = 0, mirror the bits (reverse the order).
    //-------------------------------------------------------------------------
    wire [N-1:0] reversed_swizzle_data;
    generate
        for (k = 0; k < N; k = k + 1) begin : gen_reversed_swizzle
            assign reversed_swizzle_data[k] = swizzle_data[N-1-k];
        end
    endgenerate
    wire [N-1:0] processed_swizzle_data;
    assign processed_swizzle_data = (error_detected) ? '0 : (config_in ? swizzle_data : reversed_swizzle_data);

    //-------------------------------------------------------------------------
    // Pipeline Registers
    // swizzle_reg: Captures processed_swizzle_data.
    // error_reg: Holds the swizzle-stage error status.
    // operation_reg: Applies the selected operation_mode transformation.
    // final_reg: Holds the final bit‐reversed result.
    //-------------------------------------------------------------------------
    reg [N-1:0] swizzle_reg;
    reg [N-1:0] operation_reg;
    reg [N-1:0] final_reg;
    reg         error_reg;

    //-------------------------------------------------------------------------
    // Final Bit Reversal Stage
    // Reindexes bits so that data_out[i] = operation_reg[N-1-i],
    // ensuring the most significant bit in external representations.
    //-------------------------------------------------------------------------
    wire [N-1:0] final_rev;
    generate
        for (k = 0; k < N; k = k + 1) begin : gen_final_rev
            assign final_rev[k] = operation_reg[N-1-k];
        end
    endgenerate

    // Additional helper for operation_mode 3'b010 (Reverse)
    // Computes the bit‐reversed version of swizzle_reg.
    wire [N-1:0] swizzle_rev;
    generate
        for (k = 0; k < N; k = k + 1) begin : gen_swizzle_rev
            assign swizzle_rev[k] = swizzle_reg[N-1-k];
        end
    endgenerate

    //-------------------------------------------------------------------------
    // Sequential Logic: Pipeline Stages and Operation Mode Processing
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            swizzle_reg