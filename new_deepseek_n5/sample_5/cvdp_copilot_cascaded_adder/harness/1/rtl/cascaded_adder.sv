module cascaded_adder(
    input clock,
    input rst_n,
    input i_valid,
    input [IN_DATA_WIDTH * IN_DATA_NS - 1:0] i_data,
    output [IN_DATA_WIDTH + log2(IN_DATA_NS) - 1:0] o_data,
    output o_valid
);
    // Reset handling
    always @ (rst_n) begin
        o_valid = 0;
        o_data = 0;
    end

    // Clock gating
    clock_gating o_validclk (rst_n, o_valid);

    // Data accumulation
    reg [IN_DATA_WIDTH * IN_DATA_NS - 1:0] acc_sum = 0;
    reg [IN_DATA_WIDTH * IN_DATA_NS - 1:0] current_data;

    // Process each data element
    always @ (i_valid) begin
        current_data = i_data;
        for (int i = 0; i < IN_DATA_NS; i++) begin
            acc_sum = (acc_sum << IN_DATA_WIDTH) + current_data;
            current_data = 0;
        end
    end

    // Output the accumulated sum
    o_valid = 1;
    o_data = acc_sum;
endmodule