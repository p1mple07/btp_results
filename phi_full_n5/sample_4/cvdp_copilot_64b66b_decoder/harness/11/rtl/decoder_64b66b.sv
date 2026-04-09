    always_comb begin
        type_field_valid = (type_field == {8'h1E, 8'h33, 8'h78, 8'h87, 8'h99, 8'hAA, 8'hB4, 8'hCC, 8'h2D, 8'h4B, 8'h55, 8'h66});

        case (sync_header)
            2'h01: begin
                if (type_field_valid) begin
                    decoder_data_out = {type_field, data_in[63:56]};
                    decoder_control_out = type_field_valid ? {8'h11111111} : 8'h0;
                    sync_error = 0;
                    decoder_error_out = 0;
                end else begin
                    decoder_error_out = 1;
                    sync_error = 0;
                end
            end
            2'h10: begin
                if (type_field_valid) begin
                    decoder_data_out = {data_in[63:56], type_field};
                    decoder_control_out = type_field_valid ? {8'h00010001} : 8'h0;
                    sync_error = 0;
                    decoder_error_out = 0;
                end else begin
                    decoder_error_out = 1;
                    sync_error = 0;
                end
            end
            default: begin
                decoder_error_out = 1;
                sync_error = 1;
                decoder_control_out = 8'h0;
            end
        endcase

        // Check for decoder errors based on type field
        case (type_field)
            // Add specific checks for each type field here
            // For example, check if the control bits match the expected pattern
            // If not, set decoder_error_out to 1
            // ...
        endcase
    end
