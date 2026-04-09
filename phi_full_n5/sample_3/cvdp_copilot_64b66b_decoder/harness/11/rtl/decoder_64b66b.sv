    // Define control characters
    logic [7:0] control_char;

    // Define lookup table for type field to control output mapping
    logic [7:0] type_to_ctrl_map[8'h0:8'hFF] = {
        8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000,
        8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000,
        8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000,
        8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000,
        8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000,
        8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000, 8'h00000000
    };

    // Define control characters for each type field
    logic [7:0] control_char_map[8'h0:8'hFF] = {
        8'h07, 8'h0F, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11,
        8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11,
        8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11
    };

    // Error flags
    logic sync_error, decoder_error_out;

    // Sync error detection
    always_comb begin
        sync_error = (sync_header != 2'b01 && sync_header != 2'b10);
    end

    // Type field error detection
    always_comb begin
        type_field_valid = (type_field >= 8'h0 && type_field <= 8'hFF);
        decoder_wrong_type_field = !type_field_valid;
    end

    // Control output assignment based on type field
    assign decoder_control_out = control_char_map[type_field];

    // Decoded data output
    always_comb begin
        case (type_field)
            8'h01: control_char = control_char_map[type_field];
            8'h1E: control_char = 8'h11111111;
            8'h33: control_char = 8'h00011111;
            8'h78: control_char = 8'h00000001;
            8'h87: control_char = 8'h11111110;
            8'h99: control_char = 8'h11111110;
            8'hAA: control_char = 8'h11111100;
            8'hB4: control_char = 8'h11111000;
            8'hCC: control_char = 8'h11110000;
            8'hD2: control_char = 8'h11100000;
            8'hE1: control_char = 8'h11000000;
            8'hFF: control_char = 8'h10000000;
            default: control_char = 8'h00000000;
        endcase

        // Extract decoded data based on control character
        if (control_char != 8'h00000000) begin
            decoder_data_out = {data_in[15:0], data_in[14:0], data_in[13:0], data_in[12:0], data_in[11:0], data_in[10:0],
                       data_in[9:0], data_in[8:0], data_in[7:0], data_in[6:0], data_in[5:0], data_in[4:0],
                       data_in[3:0], data_in[2:0], data_in[1:0], data_in[0:0]};
        end
    end

    // Error output logic
    assign decoder_error_out = sync_error || decoder_wrong_type_field;

    // Error handling
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_error <= 1'b0;
            decoder_error_out <= 1'b0;
            decoder_control_out <= 8'h00000000;
            data_in <= 64'h0;
        end
        else if (decoder_data_valid_in) begin
            if (sync_error) begin
                sync_error <= 1'b0;
                decoder_error_out <= 1'b0;
                decoder_control_out <= 8'h00000000;
                data_in <= 64'h0;
            end
            else if (decoder_wrong_type_field) begin
                decoder_error_out <= 1'b1;
                decoder_control_out <= 8'h00000000;
                data_in <= 64'h0;
            end
            else begin
                sync_error <= 1'b0;
                decoder_error_out <= 1'b0;
                decoder_control_out <= control_char;
                data_in <= {control_char, data_in[15:1]};
            end
        end
    end

endmodule
