module barrel_shifter_8bit (
    input data_in,
    input shift_bits,
    input left_right,
    output data_out
);

    reg [7:0] shifted_left[8], shifted_right[8];

    // Left shifts
    shifted_left[0] = data_in;
    shifted_left[1] = data_in << 1;
    shifted_left[2] = data_in << 2;
    shifted_left[3] = data_in << 3;
    shifted_left[4] = data_in << 4;
    shifted_left[5] = data_in << 5;
    shifted_left[6] = data_in << 6;
    shifted_left[7] = data_in << 7;

    // Right shifts
    shifted_right[0] = data_in;
    shifted_right[1] = data_in >> 1;
    shifted_right[2] = data_in >> 2;
    shifted_right[3] = data_in >> 3;
    shifted_right[4] = data_in >> 4;
    shifted_right[5] = data_in >> 5;
    shifted_right[6] = data_in >> 6;
    shifted_right[7] = data_in >> 7;

    // Select the output based on shift direction
    data_out = left_right ? shifted_left[shift_bits] : shifted_right[shift_bits];
endmodule