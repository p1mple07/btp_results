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
        for (j = 0; j < N; j++) begin 
            assign map_idx[j] = mapping_in[j*M +: M];
        end
    endgenerate

    always_ff @ (posedge clk) begin
        if (reset) begin
            data_out <= '0;
        end
        else begin
            for (int i = 0; i < N; i++) begin
                if (map_idx[i] >= 0 && map_idx[i] < N) begin
                    if (config_in) begin
                        data_out[i] <= data_in[map_idx[i]];
                    end
                    else begin
                        data_out[N-1-i] <= data_in[map_idx[i]];
                    end
                end
                else begin
                    data_out[i] <= '0;
                end
            end
        end
    end
endmodule