// Fix the assignment of o_valid to ensure it's only high when valid_ff[LATENCY] is high
assign o_valid = valid_ff[LATENCY];

// Fix the assignment of o_data to ensure it's only written when valid_ff[LATENCY] is high
always_comb begin : out_mapping
    if(valid_ff[LATENCY]) begin
        for (int line = 0; line < LINES; line++) begin
            for (int column = 0; column < COLUMNS; column++) begin
                if(i_encrypt) begin
                    o_data[NBW_DATA-(column*NBW_WORD + line*NBW_WORD*COLUMNS)-1-:NBW_WORD] = data_out_ff[line][column] ^ key_ff[NBW_KEY-line*NBW_WORD-1-:NBW_WORD];
                end else begin
                    o_data[NBW_DATA-(column*NBW_WORD + line*NBW_WORD*COLUMNS)-1-:NBW_WORD] = data_out_ff[line][column];
                end
            end
        end
    end else begin
        o_data = 0;
    end
end
