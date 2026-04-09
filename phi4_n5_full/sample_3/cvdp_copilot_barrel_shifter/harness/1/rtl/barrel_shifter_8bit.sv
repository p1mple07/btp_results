
module barrel_shifter_8bit(
    input logic [7:0] data_in,
    input logic [2:0] shift_bits,
    input logic left_right,
    output logic [7:0] data_out
);
    // Combine left and right shift multiplexers
    // The barrel shifter can be constructed by using multiplexers at each bit position.
    // Each bit position i is connected to a multiplexer that selects from data_in bits shifted by shift_bits.

    // We can precompute the shifted values.
    // For left shift:
    // data_in << shift_bits
    // For right shift:
    // data_in >> shift_bits
    // We can compute each bit's value using a multiplexer.
    // Alternatively, we can compute the final result by summing the shifted versions of data_in.
    // But simpler is to compute all possible shifts in parallel and then select one.

    // Compute shifted versions:
    logic [7:0] shift0;
    logic [7:0] shift1;
    logic [7:0] shift2;
    logic [7:0] shift3;
    logic [7:0] shift4;
    logic [7:0] shift5;
    logic [7:0] shift6;
    logic [7:0] shift7;

    assign shift0 = data_in; // no shift
    assign shift1 = left_right ? {data_in[6:0], 1'b0} : {1'b0, data_in[7:1]};
    assign shift2 = left_right ? {data_in[5:0], 2'b00} : {2'b00, data_in[7:2]};
    assign shift3 = left_right ? {data_in[4:0], 3'b000} : {3'b000, data_in[7:3]};
    assign shift4 = left_right ? {data_in[3:0], 4'b0000} : {4'b0000, data_in[7:4]};
    assign shift5 = left_right ? {data_in[2:0], 5'b00000} : {5'b00000, data_in[7:5]};
    assign shift6 = left_right ? {data_in[1:0], 6'b000000} : {6'b000000, data_in[7:6]};
    assign shift7 = left_right ? {data_in[0], 7'b0000000} : {7'b0000000, data_in[7]};

    // Now select the appropriate shift amount based on shift_bits.
    // Use a case statement:
    always_comb begin
        case (shift_bits)
            3'd0: data_out = shift0;
            3'd1: data_out = shift1;
            3'd2: data_out = shift2;
            3'd3: data_out = shift3;
            3'd4: data_out = shift4;
            3'd5: data_out = shift5;
            3'd6: data_out = shift6;
            3'd7: data_out = shift7;
            default: data_out = shift0;
        endcase
    end
endmodule
