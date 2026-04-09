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

    // Validate sync header
    if (sync_header != 2'b01 && sync_header != 2'b10) begin
        sync_error = 1;
        decoder_wrong_ctrl_received = 1;
    end

    // Validate type field
    case (type_field)
        0x1E: decoder_wrong_type_field = 0;
        0x33: decoder_wrong_type_field = 0;
        0x78: decoder_wrong_type_field = 0;
        0x87: decoder_wrong_type_field = 0;
        0x99: decoder_wrong_type_field = 0;
        0xAA: decoder_wrong_type_field = 0;
        0xB4: decoder_wrong_type_field = 0;
        0xCC: decoder_wrong_type_field = 0;
        0xD2: decoder_wrong_type_field = 0;
        0xE1: decoder_wrong_type_field = 0;
        0xFF: decoder_wrong_type_field = 0;
        0x2D: decoder_wrong_type_field = 0;
        0x4B: decoder_wrong_type_field = 0;
        0x55: decoder_wrong_type_field = 0;
        0x66: decoder_wrong_type_field = 0;
        default: decoder_wrong_type_field = 1;
    endcase

    // Set decoder error if type field is invalid
    decoder_error_out = decoder_wrong_type_field || decoder_wrong_ctrl_received;

    // Set control output based on type field
    case (type_field)
        0x1E: decoder_control_out = 8'b11111111;
        0x33: decoder_control_out = 8'b00011111;
        0x78: decoder_control_out = 8'b00000001;
        0x87: decoder_control_out = 8'b11111110;
        0x99: decoder_control_out = 8'b11111110;
        0xAA: decoder_control_out = 8'b11111100;
        0xB4: decoder_control_out = 8'b11111000;
        0xCC: decoder_control_out = 8'b11110000;
        0xD2: decoder_control_out = 8'b11100000;
        0xE1: decoder_control_out = 8'b11000000;
        0xFF: decoder_control_out = 8'b10000000;
        0x2D: decoder_control_out = 8'b00011111;
        0x4B: decoder_control_out = 8'b11110001;
        0x55: decoder_control_out = 8'b00010001;
        0x66: decoder_control_out = 8'b00010001;
        default: decoder_control_out = 8'b00000000;
    endcase

    // Set data output based on type field
    case (type_field)
        0x1E: data_out = {E7, E6, E5, E4, E3, E2, E1, E0};
        0x33: data_out = {D6, D5, D4, S4, I3, I2, I1, I0};
        0x78: data_out = {D6, D5, D4, D3, D2, D1, D0, S0};
        0x87: data_out = {I7, I6, I5, I4, I3, I2, I1, T0};
        0x99: data_out = {I7, I6, I5, I4, D2, D1, D0, T1};
        0xAA: data_out = {I7, I6, I5, I4, I3, T2, D1, D0};
        0xB4: data_out = {I7, I6, I5, I4, T3, D2, D1, D0};
        0xCC: data_out = {I7, I6, I5, T4, D3, D2, D1, D0};
        0xD2: data_out = {I7, I6, T5, D4, D3, D2, D1, D0};
        0xE1: data_out = {I7, T6, D5, D4, D3, D2, D1, D0};
        0xFF: data_out = {T7, D6, D5, D4, D3, D2, D1, D0};
        0x2D: data_out = {D6, D5, D4, Q4, I3, I2, I1, I0};
        0x4B: data_out = {I7, I6, I5, I4, D2, D1, D0, Q0};
        0x55: data_out = {D6, D5, D4, Q4, D2, D1, D0, Q0};
        0x66: data_out = {D6, D5, D4, S4, D2, D1, D0, Q0};
        default: data_out = 64'h00000000;
    endcase

    decoder_data_out = data_out;
    decoder_control_out = decoder_control_out;
endmodule