module cascaded_adder(
    input clock,
    input rst_n,
    input i_valid,
    input [IN_DATA_WIDTH * IN_DATA_NS - 1:0] i_data,
    output [IN_DATA_WIDTH + log2(IN_DATA_NS):0] o_data,
    output o_valid
);

    // Initialize sum register to 0
    reg [IN_DATA_WIDTH + log2(IN_DATA_NS):0] sum_reg = 0;

    // Current element register
    reg [IN_DATA_WIDTH - 1:0] current_element;

    // Load the first element
    if (i_valid) begin
        current_element = i_data;
    end

    // Add each element sequentially
    for (int i = 0; i < IN_DATA_NS; i = i + 1) begin
        // Add current element to sum
        sum_reg = sum_reg + current_element;
        // Update current element for next iteration
        if (i < IN_DATA_NS - 1) begin
            current_element = i_data;
        end
    end

    // After all additions, output the result
    always clock positive edge #1 begin
        if (rst_n) begin
            o_valid = 0;
            sum_reg = 0;
        else if (i_valid) begin
            o_valid = 1;
            o_data = sum_reg;
        end
    end
endmodule