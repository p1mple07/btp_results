module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
)(
    input wire clk,
    input wire reset,
    // Serial Input data lanes
    input wire [N-1:0]                 data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input wire [N*$clog2(N)-1:0]       mapping_in,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input wire                           config_in,
    // Serial Output data lanes
    output wire [N-1:0]                data_out
);
    localparam int M = $clog2(N);
    wire [M-1:0] map_idx [N];
    reg [N-1:0] processed_swizzle_data;
    reg [N-1:0] temp_swizzled_data;
    reg [N-1:0] temp_error_flag;
    reg [N-1:0] error_reg;
    reg [N-1:0] operation_reg;

    generate
        for (genvar i = 0; i < N; i++) begin : lane_mapping
            assign map_idx[i] = mapping_in[i*M +: M];
        end
    endgenerate

    always_ff @(posedge clk) begin
        temp_swizzled_data <= {data_in[map_idx]} & (~map_idx[N-1]);
        processed_swizzle_data <= temp_swizzled_data;

        if (config_in) begin
            operation_reg <= ~processed_swizzle_data;
        end
        else begin
            operation_reg <= processed_swizzle_data;
        end
        
        error_reg <= '0;
        for (int j = 0; j < N; j++) begin
            if (map_idx[j] >= 0 && map_idx[j] < N) begin
                if (config_in) begin
                    data_out[i] <= data_in[map_idx[j]];
                end
                else begin
                    data_out[N-1-j] <= data_in[map_idx[j]];
                end
            end
            else begin
                data_out[i] <= '0;
            end
        end
    end
endmodule