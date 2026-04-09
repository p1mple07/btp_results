module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,
    input left_right,
    input [data_width-1:0] mask,
    input enable,
    input enable_parity,
    input condition,
    input bit_op_type,
    input [data_width-1:0] mask_for_set_clear,
    input enable_parity,
    output reg [data_width-1:0] data_out,
    output reg parity_out,
    output reg error[1:0],
    output reg [7:0] condition,
    output reg bit_op_type
);

// … existing core logic …

always @(*) begin
    if (!enable) begin
        data_out = data_out;
        error[1] = 1;   // out-of-range shift
        error[0] = 0;   // no other error
    end else begin
        // …
    end
end

// New conditional bit manipulation block
always @(*) begin
    if (bit_op_type == 2'b00) begin
        // Toggle
        data_out = data_in ^ condition;
    end else if (bit_op_type == 2'b01) begin
        // Set
        data_out = data_in | condition;
    end else if (bit_op_type == 2'b10) begin
        // Clear
        data_out = data_in & ~condition;
    end else begin
        data_out = {data_width{1'b0}};
        error[1] = 1;   // invalid operation
        error[0] = 1;   // double error
    end
end

// … rest of the code …

endmodule
