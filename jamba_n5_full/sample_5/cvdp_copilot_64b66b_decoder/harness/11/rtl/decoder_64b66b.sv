module decoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic         decoder_data_valid_in,
    input  logic [65:0] decoder_data_in,
    output logic [63:0]  decoder_data_out,
    output logic [7:0]   decoder_control_out,
    output logic         sync_error,
    output logic         decoder_error_out
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

    // Sync header validation
    always @(*) begin
        if (!sync_header[1:0]) begin
            sync_error = 1;
            decoder_error_out = 1;
        end else begin
            // Type field validation
            type_field_valid = (type_field in {
                2'b0x1E, 2'b0x33, 2'b0x78, 2'b0x87, 2'b0x99, 2'b0xAA,
                2'b0xB4, 2'b0xC?  // Note: actual list must be complete
                2'b0xD2, 2'b0xE1, 2'b0xFF, 2'b0x2D, 2'b0x4B, 2'b0x55,
                2'b0x66
            });

            if (!type_field_valid) begin
                decoder_error_out = 1;
            end else begin
                // Mapping to control output based on type field
                case (type_field)
                    2'b0x1E: decoder_control_out = 8'b11111111;
                    2'b0x33: decoder_control_out = 8'b00011111;
                    2'b0x78: decoder_control_out = 8'b00000001;
                    2'b0x87: decoder_control_out = 8'b11111110;
                    2'b0x99: decoder_control_out = 8'b11111110;
                    2'b0xAA: decoder_control_out = 8'b11111100;
                    2'b0xB4: decoder_control_out = 8'b11111000;
                    2'b0xC?  // Continue with the remaining cases
                    2'b0xD2: decoder_control_out = 8'b11100000;
                    2'b0xE1: decoder_control_out = 8'b11000000;
                    2'b0xFF: decoder_control_out = 8'b10000000;
                    2'b0x2D: decoder_control_out = 8'b00011111;
                    2'b0x4B: decoder_control_out = 8'b11110001;
                    2'b0x55: decoder_control_out = 8'b00010001;
                    2'b0x66: decoder_control_out = 8'b00010001;
                    default: decoder_control_out = 8'b00000000;
                endcase
            end
        end
    end

    // Generate control characters for output
    always @(*) begin
        if (decoder_wrong_ctrl_received) begin
            decoder_control_out = 8'b00000000;
        end else if (decoder_error_out) begin
            decoder_control_out = 8'b00000000;
        end else begin
            decoder_control_out = 8'b0;
            decoder_data_out = 64'b0;
        end
    end

endmodule
