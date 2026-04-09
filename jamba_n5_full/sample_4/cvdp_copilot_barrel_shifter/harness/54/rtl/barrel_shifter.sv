module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4  // Shift width for the core logic
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,               // 1 = left shift, 0 = right shift
    input rotate_left_right,        // 1 = rotate, 0 = normal shift
    input arithmetic_shift,         // 1 = arithmetic shift, 0 = logical shift
    output reg [data_width-1:0] data_out,
    output wire error
);

// Mode selection (3 bits)
localparam bit [2:0] mode_sel = {3'b000, 3'b001, 3'b010, 3'b011, 3'b100};

always @(*) begin
    case (mode)
        0: begin  // Logical Shift
            data_out <= shift_logic(data_in, shift_bits);
        end
        1: begin  // Arithmetic Shift with Sign Extension
            data_out <= arithmetic_shift_logic(data_in, shift_bits);
        end
        2: begin  // Rotate
            data_out <= rotate(data_in, shift_bits, left_right);
        end
        3: begin  // Custom Mask‑Based Shift
            data_out <= masked_shift(data_in, shift_bits, mask);
        end
        4: begin  // XOR with Shifted Data and Mask
            data_out <= xor_shifted(data_in, mask);
        end
        others: begin
            data_out <= 0;
            error <= 1;
        end
    endcase
endprocess

function shift_logic(input [data_width-1:0] data_in, input [shift_bits_width-1:0] shift_bits);
    assign data_out = data_in >> shift_bits;
endfunction

function rotate(input [data_width-1:0] data_in, input [shift_bits_width-1:0] shift_bits, input left_right);
    if (left_right)
        data_out = data_in << shift_bits;
    else
        data_out = data_in >> shift_bits;
endfunction

function masked_shift(input [data_width-1:0] data_in, input [shift_bits_width-1:0] shift_bits, input [data_width-1:0] mask);
    assign data_out = (data_in << shift_bits) & mask;
endfunction

function xor_shifted(input [data_width-1:0] data_in, input [shift_bits_width-1:0] shift_bits, input [data_width-1:0] mask);
    assign data_out = (data_in << shift_bits) ^ mask;
endfunction

endmodule
