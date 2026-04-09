module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
)(
    input clk,
    input reset,
    // Serial Input data lanes
    input  logic [N-1:0]                 data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide
    input  logic [$clog2(N)-1:0]        mapping_in,
    // Control signal: 0 - mapping is LSB to MSB, 1 - mapping is MSB to LSB
    input  logic                          config_in,
    // Serial Output data lanes
    output logic [N-1:0]                 data_out
);
    localparam int M = $clog2(N);
    logic [M-1:0] map_idx [N];
    logic [N-1:0] processed_swizzle_data, temp_swizzled_data;
    logic          temp_error_flag, error_flag;

    always_ff @(posedge clk) begin
        error_flag <= 0;
        for (int i = 0; i < N; i++) begin
            if (mapping_in[i*M +: M] >= N) begin
                temp_error_flag <= 1;
                error_flag         <= 1;
            end
        end
        if (!reset) begin
            processed_swizzle_data <= {N{1'bx}};
        end
        else begin
            for (int i = 0; i < N; i++) begin
                if (mapping_in[i*M +: M] < N) begin
                    processed_swizzle_data[i] <= data_in[mapping_in[i*M +: M]];
                end
                else begin
                    processed_swizzle_data[i] <= 1'b0;
                end
            end
        end
        for (int i = 0; i < N; i++) begin
            if (map_idx[i] >= 0 && map_idx[i] < N) begin
                if (config_in) begin
                    temp_swizzled_data[i] <= data_in[map_idx[i]];
                end
                else begin
                    temp_swizzled_data[N-1-i] <= data_in[map_idx[i]];
                end
            end
            else begin
                temp_swizzled_data[i] <= 1'b0;
            end
        end

        if (!reset) begin
            data_out <= {N{1'bx}};
        end
        else begin
            if (config_in) begin
                data_out <= temp_swizzled_data;
            end
            else begin
                data_out <= temp_swizzled_data;
            end

            if (operation_mode == 3'b000) begin
                data_out <= processed_swizzle_data;
            end
            else if (operation_mode == 3'b001) begin
                data_out <= reverse_data(processed_swizzle_data);

                function automatic reverse_data(input [N-1:0] data_in);
                    logic [N-1:0] reversed_data;
                    for (int i = N-1 downto 0.
                    reversed_data[i] <= data_in[i];
                endfunction
            end
            else if (operation_mode == 3'b010) begin
                data_out <= swap_data(processed_swizzle_data);
                function automatic swap_data(input [N-1:0] data_in);
                    logic [N-1:0] swapped_data;
                    for (int i = 0; i < N; i++): swapped_data[i] <= data_in[i]
                endfunction
            end
            else if (operation_mode == 3'b011) begin
                data_out <= processed_swizzle_data;
            end
            else if (operation_mode == 3'b100) begin
                data_out <= processed_swizzle_data;
            end
            else begin
                data_out <= processed_swizzle_data;
            end
        end
    end

endmodule