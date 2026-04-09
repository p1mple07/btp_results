module swizzler #(
    parameter int N = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic [N-1:0] data_in,
    input  logic [N*($clog2(N+1))-1:0] mapping_in,
    input  logic config_in,
    input  logic [2:0] operation_mode,
    output logic [N-1:0] data_out,
    output logic error_flag
);

    localparam int M = $clog2(N+1);

    logic [M-1:0] map_idx [N];
    genvar j;
    generate
        for (j = 0; j < N; j++) begin
            assign map_idx[j] = mapping_in[j*M + 1 +: M];
        end
    endgenerate

    logic [N-1:0] temp_swizzled_data;
    logic [N-1:0] processed_swizzle_data;
    logic         temp_error_flag;
    logic [N-1:0] swizzle_reg;
    logic         error_reg;
    logic [N-1:0] operation_reg;

    always_comb begin
        temp_error_flag = 1'b0;

        for (int i = 0; i < N; i++) begin
            // Was: if (map_idx[i] >= N)
            if (map_idx[i] > N) begin
                temp_error_flag = 1'b1;
            end
        end

        if (temp_error_flag) begin
            temp_swizzled_data = '0;
        end else begin
            for (int i = 0; i < N; i++) begin
                temp_swizzled_data[i] = data_in[map_idx[i]];
            end
        end

        for (int i = 0; i < N; i++) begin
            if (config_in) begin
                processed_swzzle_data[i] = temp_swizzled_data[i];
            end else begin
                processed_swizzle_data[i] = temp_swizzled_data[N - 1 - i];
            end
        end

        for (int i = 0; i < N; i++) begin
            if (operation_mode == 3'b000) begin
                processed_swizzle_data[i] = swizzle_reg[N-1-i];
            end else begin
                // TODO
            end
        end

        for (int i = 0; i < N; i++) begin
            // TODO
        end

        for (int i = 0; i < N; i++) begin
            // TODO
        end

        for (int i = 0; i < N; i++) begin
            // TODO
        end
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

    always_ff @(posedge clk or posedge reset) begin
        // TODO
    endgenerate

endmodule