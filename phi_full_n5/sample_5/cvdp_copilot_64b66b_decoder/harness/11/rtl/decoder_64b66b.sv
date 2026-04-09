// Define control characters
localparam logic [7:0] /I/ = 8'h07;
localparam logic [7:0] /S/ = 8'hFB;
localparam logic [7:0] /T/ = 8'hFD;
localparam logic [7:0] /E/ = 8'hFE;
localparam logic [7:0] /Q/ = 8'h9C;

// Type field to control output mapping
localparam logic [7:0] type_field_map [7:0] = '{
    8'h1E: 8'h11111111,
    8'h33: 8'h00011111,
    8'h78: 8'h00000001,
    8'h87: 8'h00000001,
    8'h99: 8'h00000001,
    8'hAA: 8'h00000001,
    8'hB4: 8'h00000001,
    8'hCC: 8'h00000001,
    8'hD2: 8'h00000001,
    8'hE1: 8'h00000001,
    8'h2D: 8'h00000001,
    8'h4B: 8'h00000001,
    8'h55: 8'h00000001,
    8'h66: 8'h00000001
};

// Control characters to be inserted based on type field
localparam logic [7:0] control_char_map [7:0] = '{
    8'h1E: /I/,
    8'h33: /I/,
    8'h78: /I/,
    8'h87: /I/,
    8'h99: /I/,
    8'hAA: /I/,
    8'hB4: /I/,
    8'hCC: /I/,
    8'hD2: /I/,
    8'hE1: /I/,
    8'h2D: /I/,
    8'h4B: /I/,
    8'h55: /I/,
    8'h66: /I/
};

always_ff @(posedge clk_in or negedge rst_in) begin
    if (!rst_in) begin
        decoder_data_out <= 64'h0;
        decoder_control_out <= 8'h0;
        sync_error <= 1;
        decoder_error_out <= 1;
    end else begin
        // Check sync header validity
        if (sync_header != 2'b01 && sync_header != 2'b10) begin
            sync_error <= 1;
        end else begin
            sync_error <= 0;
        end

        // Extract type field and check if valid
        type_field_valid = (type_field_map[type_field] != 8'h0);
        if (!type_field_valid) begin
            decoder_error_out <= 1;
        end else begin
            decoder_error_out <= 0;
        end

        // Decode data based on type field
        case (type_field)
            8'h1E: decoder_data_out <= type_field_map[type_field];
            8'h33: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'h78: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'h87: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'h99: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'hAA: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'hB4: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'hCC: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'hD2: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'hE1: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'h2D: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'h4B: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'h55: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            8'h66: decoder_data_out <= {type_field_map[type_field], control_char_map[type_field]};
            default: begin
                decoder_data_out <= 64'h0;
                decoder_control_out <= 8'h0;
                sync_error <= 1;
                decoder_error_out <= 1;
            end
        endcase

        // Insert control characters into decoded data output
        decoder_data_out = {decoder_data_out, control_char_map[type_field]};
    end
end

endmodule
