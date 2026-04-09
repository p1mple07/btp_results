// ----------------------------------------
// - Assign outputs
// ----------------------------------------

// Map output values from lines x columns to a single dimension
always_comb begin : out_mapping
    if(valid_ff[LATENCY]) begin
        for (int line = 0; line < LINES; line++) begin
            for (int column = 0; column < COLUMNS; column++) begin
                if(i_encrypt) begin
                    // Ensure that the output data is only valid when i_encrypt is asserted
                    if (i_encrypt) begin
                        o_data[NBW_DATA-(column*NBW_WORD + line*NBW_WORD*COLUMNS)-1-:NBW_WORD] = data_out_ff[line][column] ^ key_ff[NBW_KEY-line*NBW_WORD-1-:NBW_WORD];
                    end
                end else begin
                    // For decryption, ensure that the output data is only valid when i_encrypt is not asserted
                    if (!i_encrypt) begin
                        o_data[NBW_DATA-(column*NBW_WORD + line*NBW_WORD*COLUMNS)-1-:NBW_WORD] = data_out_ff[line][column];
                    end
                end
            end
        end
    end else begin
        // Ensure that o_data is cleared when valid_ff is not asserted
        o_data = 0;
    end
end

// Correctly assign o_valid based on the validity of the output data
assign o_valid = valid_ff[LATENCY];

// Ensure that o_valid is only asserted when i_encrypt is asserted and data_out_ff has been computed
assign o_valid = i_encrypt & valid_ff[LATENCY];
