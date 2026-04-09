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

    // Type field to control and data mapping
    type_field_valid = 1;
    decoder_wrong_type_field = 0;

    case(type_field)
        0x1E: begin
            decoder_control_out = 8'b11111111;
            decoder_data_out = 64'hE7E6E5E4E3E2E1E0;
        end
        0x33: begin
            decoder_control_out = 8'b00011111;
            decoder_data_out = 64'hD6D5D4S4I3I2I1I0;
        end
        0x78: begin
            decoder_control_out = 8'b00000001;
            decoder_data_out = 64'hD6D5D4D3D2D1D0S0;
        end
        0x87: begin
            decoder_control_out = 8'b11111110;
            decoder_data_out = 64'hI7I6I5I4I3I2T1D0;
        end
        0x99: begin
            decoder_control_out = 8'b11111110;
            decoder_data_out = 64'hI7I6I5I4I3T2D1D0;
        end
        0xAA: begin
            decoder_control_out = 8'b11111100;
            decoder_data_out = 64'hI7I6I5I4T3D2D1D0;
        end
        0xB4: begin
            decoder_control_out = 8'b11111000;
            decoder_data_out = 64'hI7I6I5T4D3D2D1D0;
        end
        0xCC: begin
            decoder_control_out = 8'b11110000;
            decoder_data_out = 64'hI7I6T5D4D3D2D1D0;
        end
        0xD2: begin
            decoder_control_out = 8'b11100000;
            decoder_data_out = 64'hI7I6T5D4D3D2D1D0;
        end
        0xE1: begin
            decoder_control_out = 8'b11000000;
            decoder_data_out = 64'hI7I6T6D5D4D3D2D1D0;
        end
        0xFF: begin
            decoder_control_out = 8'b10000000;
            decoder_data_out = 64'hT7D6D5D4D3D2D1D0;
        end
        0x2D: begin
            decoder_control_out = 8'b00011111;
            decoder_data_out = 64'hD6D5D4Q4I3I2I1I0;
        end
        0x4B: begin
            decoder_control_out = 8'b11110001;
            decoder_data_out = 64'hI7I6I5I4D2D1D0Q0;
        end
        0x55: begin
            decoder_control_out = 8'b00010001;
            decoder_data_out = 64'hD6D5D4Q4D2D1D0Q0;
        end
        0x66: begin
            decoder_control_out = 8'b00010001;
            decoder_data_out = 64'hD6D5D4S4D2D1D0Q0;
        end
        default:
            decoder_wrong_type_field = 1;
            decoder_control_out = 8'b00000000;
            decoder_data_out = 64'h00000000;
            sync_error = 1;
            decoder_error_out = 1;
            break;
    endcase

    // Error handling
    sync_error = (sync_header != 2'b01 && sync_header != 2'b10);

    decoder_error_out = (type_field_valid ? decoder_wrong_type_field : 0) |
                        (data_in != (type_field == 0x1E ? 64'hE7E6E5E4E3E2E1E0 :
                                      type_field == 0x33 ? 64'hD6D5D4S4I3I2I1I0 :
                                      type_field == 0x78 ? 64'hD6D5D4D3D2D1D0S0 :
                                      type_field == 0x87 ? 64'hI7I6I5I4I3I2T1D0 :
                                      type_field == 0x99 ? 64'hI7I6I5I4I3T2D1D0 :
                                      type_field == 0xAA ? 64'hI7I6I5I4T3D2D1D0 :
                                      type_field == 0xB4 ? 64'hI7I6I5T4D3D2D1D0 :
                                      type_field == 0xCC ? 64'hI7I6T5D4D3D2D1D0 :
                                      type_field == 0xD2 ? 64'hI7I6T5D4D3D2D1D0 :
                                      type_field == 0xE1 ? 64'hI7I6T6D5D4D3D2D1D0 :
                                      type_field == 0xFF ? 64'hT7D6D5D4D3D2D1D0 :
                                      type_field == 0x2D ? 64'hD6D5D4Q4I3I2I1I0 :
                                      type_field == 0x4B ? 64'hI7I6I5I4D2D1D0Q0 :
                                      type_field == 0x55 ? 64'hD6D5D4Q4D2D1D0Q0 :
                                      type_field == 0x66 ? 64'hD6D5D4S4D2D1D0Q0));