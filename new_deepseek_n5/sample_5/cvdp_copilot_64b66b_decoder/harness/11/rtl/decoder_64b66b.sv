module decoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic         decoder_data_valid_in, // Input data valid signal
    input  logic [65:0]  decoder_data_in,     // 66-bit encoded input
    output logic [63:0]  decoder_data_out,    // Decoded 64-bit data output
    output logic [7:0]   decoder_control_out, // Decoded 8-bit control output
    output logic         sync_error,          // Sync error flag
    output logic         decoder_error_out    // Type field error flag
);

    logic [1:0] sync_header;
    logic [7:0] type_field;
    logic [63:0] data_in;
    logic type_field_valid;
    logic decoder_wrong_ctrl_received;
    logic decoder_wrong_type_field;

    assign sync_header = decoder_data_in[65:64];
    assign type_field = decoder_data_in[63:56];
    assign data_in = decoder_data_in[55:0];

    logic decoder_type_field_map = 1;
    case (type_field)
        0x1E: decoder_type_field_map = 2;
        0x33: decoder_type_field_map = 3;
        0x78: decoder_type_field_map = 4;
        0x87: decoder_type_field_map = 5;
        0x99: decoder_type_field_map = 6;
        0xAA: decoder_type_field_map = 7;
        0xB4: decoder_type_field_map = 8;
        0xCC: decoder_type_field_map = 9;
        0xD2: decoder_type_field_map = 10;
        0xE1: decoder_type_field_map = 11;
        0xFF: decoder_type_field_map = 12;
        0x2D: decoder_type_field_map = 13;
        0x4B: decoder_type_field_map = 14;
        0x55: decoder_type_field_map = 15;
        0x66: decoder_type_field_map = 16;
        default: decoder_type_field_map = 0;
    endcase

    if (decoder_type_field_map == 0)
        decoder_wrong_type_field = 1;
    else
        case (decoder_type_field_map)
            2: decoder_control_out = 8'b11111111;
               decoder_data_out = {E7, E6, E5, E4, E3, E2, E1, E0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
               decoder_data_out = data_in;
               decoder_control_out = 8'b11111111;
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            3: decoder_control_out = 8'b00011111;
               decoder_data_out = {D6, D5, D4, S4, I3, I2, I1, I0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            4: decoder_control_out = 8'b00000001;
               decoder_data_out = {D6, D5, D4, D3, D2, D1, D0, S0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            5: decoder_control_out = 8'b11111110;
               decoder_data_out = {I7, I6, I5, I4, I3, I2, I1, T0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            6: decoder_control_out = 8'b11111110;
               decoder_data_out = {I7, I6, I5, I4, I3, I2, T1, D0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            7: decoder_control_out = 8'b11111100;
               decoder_data_out = {I7, I6, I5, I4, I3, T2, D1, D0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            8: decoder_control_out = 8'b11111000;
               decoder_data_out = {I7, I6, I5, I4, T3, D2, D1, D0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            9: decoder_control_out = 8'b11110000;
               decoder_data_out = {I7, I6, I5, T4, D3, D2, D1, D0};
               decoder_wrong_ctrl_received = 0;
               decoder_type_field_valid = 1;
               sync_error = 0;
               decoder_error_out = 0;
            10: decoder_control_out = 8'b11100000;
                decoder_data_out = {I7, I6, T5, D4, D3, D2, D1, D0};
                decoder_wrong_ctrl_received = 0;
                decoder_type_field_valid = 1;
                sync_error = 0;
                decoder_error_out = 0;
            11: decoder_control_out = 8'b11000000;
                decoder_data_out = {I7, T6, D5, D4, D3, D2, D1, D0};
                decoder_wrong_ctrl_received = 0;
                decoder_type_field_valid = 1;
                sync_error = 0;
                decoder_error_out = 0;
            12: decoder_control_out = 8'b10000000;
                decoder_data_out = {T7, D6, D5, D4, D3, D2, D1, D0};
                decoder_wrong_ctrl_received = 0;
                decoder_type_field_valid = 1;
                sync_error = 0;
                decoder_error_out = 0;
            13: decoder_control_out = 8'b00011111;
                decoder_data_out = {D6, D5, D4, Q4, I3, I2, I1, I0};
                decoder_wrong_ctrl_received = 0;
                decoder_type_field_valid = 1;
                sync_error = 0;
                decoder_error_out = 0;
            14: decoder_control_out = 8'b11110001;
                decoder_data_out = {I7, I6, I5, I4, D2, D1, D0, Q0};
                decoder_wrong_ctrl_received = 0;
                decoder_type_field_valid = 1;
                sync_error = 0;
                decoder_error_out = 0;
            15: decoder_control_out = 8'b00010001;
                decoder_data_out = {D6, D5, D4, Q4, D2, D1, D0, Q0};
                decoder_wrong_ctrl_received = 0;
                decoder_type_field_valid = 1;
                sync_error = 0;
                decoder_error_out = 0;
            16: decoder_control_out = 8'b00010001;
                decoder_data_out = {D6, D5, D4, S4, D2, D1, D0, Q0};
                decoder_wrong_ctrl_received = 0;
                decoder_type_field_valid = 1;
                sync_error = 0;
                decoder_error_out = 0;
            default: decoder_wrong_type_field = 1;
    endcase

    decoder_error_out = decoder_wrong_type_field || decoder_wrong_ctrl_received;

endmodule