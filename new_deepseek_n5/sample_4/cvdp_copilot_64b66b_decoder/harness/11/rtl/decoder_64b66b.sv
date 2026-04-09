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

    // Type field validation and decoding
    case(type_field)
        // Case for 0x1E
        0x1E: 
            decoder_control_out = 8'b11111111;
            decoder_data_out = data_in[63:0] ^ 0xE7;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x33
        0x33: 
            decoder_control_out = 8'b00011111;
            decoder_data_out = data_in[63:0] ^ 0xD6;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x78
        0x78: 
            decoder_control_out = 8'b00000001;
            decoder_data_out = data_in[63:0] ^ 0xD7;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x87
        0x87: 
            decoder_control_out = 8'b11111110;
            decoder_data_out = data_in[63:0] ^ 0x8F;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x99
        0x99: 
            decoder_control_out = 8'b11111110;
            decoder_data_out = data_in[63:0] ^ 0x9F;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0xAA
        0xAA: 
            decoder_control_out = 8'b11111100;
            decoder_data_out = data_in[63:0] ^ 0xAF;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0xB4
        0xB4: 
            decoder_control_out = 8'b11111000;
            decoder_data_out = data_in[63:0] ^ 0xBF;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0xCC
        0xCC: 
            decoder_control_out = 8'b11110000;
            decoder_data_out = data_in[63:0] ^ 0xCC;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0xD2
        0xD2: 
            decoder_control_out = 8'b11100000;
            decoder_data_out = data_in[63:0] ^ 0xDF;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0xE1
        0xE1: 
            decoder_control_out = 8'b11000000;
            decoder_data_out = data_in[63:0] ^ 0xE1;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0xFF
        0xFF: 
            decoder_control_out = 8'b10000000;
            decoder_data_out = data_in[63:0] ^ 0xFF;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x2D
        0x2D: 
            decoder_control_out = 8'b00011111;
            decoder_data_out = data_in[63:0] ^ 0xD6;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x4B
        0x4B: 
            decoder_control_out = 8'b11110001;
            decoder_data_out = data_in[63:0] ^ 0xB7;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x55
        0x55: 
            decoder_control_out = 8'b00010001;
            decoder_data_out = data_in[63:0] ^ 0x77;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        // Case for 0x66
        0x66: 
            decoder_control_out = 8'b00010001;
            decoder_data_out = data_in[63:0] ^ 0x77;
            type_field_valid = 1;
            decoder_wrong_ctrl_received = 0;
            decoder_wrong_type_field = 0;
            break;
        default:
            decoder_wrong_type_field = 1;
            decoder_wrong_ctrl_received = 0;
            type_field_valid = 0;
            break;
    // Error flags
    sync_error = sync_header != (2'b01 || 2'b10);
    decoder_error_out = decoder_wrong_type_field || decoder_wrong_ctrl_received;
    decoder_wrong_type_field = 0;
    decoder_wrong_ctrl_received = 0;

endmodule