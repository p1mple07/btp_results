// Additional logic for decoding, error detection, and output control

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        decoder_data_out <= 64'h00000000;
        decoder_control_out <= 8'b00000000;
        sync_error <= 1'b0;
        decoder_error_out <= 1'b0;
    end else begin
        // Decoding logic based on sync header and type field
        case (sync_header)
            2'h01: begin
                if (type_field_valid) begin
                    decoder_data_out <= data_in;
                    decoder_control_out <= 8'h0; // No special control character
                end else begin
                    sync_error <= 1'b1;
                    decoder_error_out <= 1'b0;
                end
            end
            2'h10: begin
                if (type_field_valid) begin
                    decoder_data_out <= data_in;
                    case (type_field)
                        0x1E: decoder_control_out <= 8'h11111111;
                        0x33: decoder_control_out <= 8'h00011111;
                        0x78: decoder_control_out <= 8'h00000001;
                        0x87: decoder_control_out <= 8'h00000001;
                        0x99: decoder_control_out <= 8'h00000001;
                        0xAA: decoder_control_out <= 8'h00000001;
                        0xB4: decoder_control_out <= 8'h00000001;
                        0xCC: decoder_control_out <= 8'h00000001;
                        0xD2: decoder_control_out <= 8'h00000001;
                        0xE1: decoder_control_out <= 8'h00000001;
                        0xFF: decoder_control_out <= 8'h00000001;
                        default: decoder_control_out <= 8'h00000000;
                    endcase
                    decoder_data_out <= data_in;
                end else begin
                    decoder_error_out <= 1'b1;
                    sync_error <= 1'b1;
                end
            end
            default: begin
                sync_error <= 1'b1;
                decoder_error_out <= 1'b1;
            end
        endcase
    end
end

// Control character insertion logic
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        // Reset control characters to idle
        for (int i = 7; i >= 0; i--) begin
            decoder_control_out[i] <= 8'h07; // /I/
        end
    end else begin
        // Insert control characters based on type field
        case (type_field)
            0x1E: decoder_control_out <= 8'h07;
            0x33: decoder_control_out <= 8'h07;
            0x78: decoder_control_out <= 8'h07;
            0x87: decoder_control_out <= 8'h07;
            0x99: decoder_control_out <= 8'h07;
            0xAA: decoder_control_out <= 8'h07;
            0xB4: decoder_control_out <= 8'h07;
            0xCC: decoder_control_out <= 8'h07;
            0xD2: decoder_control_out <= 8'h07;
            0xE1: decoder_control_out <= 8'h07;
            0xFF: decoder_control_out <= 8'h07;
            default: decoder_control_out <= 8'h00;
        endcase
    end
end
