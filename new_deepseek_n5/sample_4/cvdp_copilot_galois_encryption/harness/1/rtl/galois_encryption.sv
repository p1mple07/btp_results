// ... [previous code remains unchanged until the data_regs section] ...

// Data registers
localparam LATENCY  = 'd3;
localparam NBW_WORD  = 'd4;
localparam MOD_POLY = 8'h1B;
localparam LINES    = 'd4;
localparam COLUMNS  = 'd4;

// Calculate GF(2^8) multiplications by 2, 4 and 8
always_comb begin : ctrl_regs
    for (int line = 0; line < LINES; line++) begin
        for (int column = 0; column < COLUMNS; column++) begin
            if(i_encrypt) begin
                data_in[line][column] <= data_in[line][column] << 1 ^ MOD_POLY;
            end else begin
                data_in[line][column] <= data_in[line][column] << 1 ^ MOD_POLY;
            end
        end
    end
end

// Calculate GF(2^8) multiplications by the values in the polynomial
always_comb begin : multiply_gf2_4_8
    for (int line = 0; line < LINES; line++) begin
        for (int column = 0; column < COLUMNS; column++) begin
            if(i_encrypt) begin
                data_xtimes2_nx[line][column] = data_in[line][column] << 1 ^ MOD_POLY;
                data_xtimes4_nx[line][column] = data_in[line][column] << 2 ^ MOD_POLY;
                data_xtimes8_nx[line][column] = data_in[line][column] << 4 ^ MOD_POLY;
            end else begin
                data_xtimes2_nx[line][column] = data_in[line][column] << 1 ^ MOD_POLY;
                data_xtimes4_nx[line][column] = data_in[line][column] << 2 ^ MOD_POLY;
                data_xtimes8_nx[line][column] = data_in[line][column] << 4 ^ MOD_POLY;
            end
        end
    end
end

// Calculate output matrix
always_comb begin : out_matrix
    if(i_encrypt) begin
        for (int column = 0; column < COLUMNS; column++) begin
            data_out[0][column] = data_xtimes2_nx[0][column] ^ data_xtimes3_nx[1][column] ^ data_in[2][column] ^ data_in[3][column];
            data_out[1][column] = data_xtimes2_nx[1][column] ^ data_xtimes3_nx[2][column] ^ data_in[3][column] ^ data_in[0][column];
            data_out[2][column] = data_xtimes2_nx[2][column] ^ data_xtimes3_nx[3][column] ^ data_in[0][column] ^ data_in[1][column];
            data_out[3][column] = data_xtimes2_nx[3][column] ^ data_xtimes3_nx[0][column] ^ data_in[1][column] ^ data_in[2][column];
        end
    end else begin
        for (int column = 0; column < COLUMNS; column++) begin
            data_out[0][column] = data_xtimesE_nx[0][column] ^ data_xtimesB_nx[1][column] ^ data_in[2][column] ^ data_in[3][column];
            data_out[1][column] = data_xtimesE_nx[1][column] ^ data_xtimesB_nx[2][column] ^ data_in[3][column] ^ data_in[0][column];
            data_out[2][column] = data_xtimesE_nx[2][column] ^ data_xtimesB_nx[3][column] ^ data_in[0][column] ^ data_in[1][column];
            data_out[3][column] = data_xtimesE_nx[3][column] ^ data_xtimesB_nx[0][column] ^ data_in[1][column] ^ data_in[2][column];
        end
    end
end

// Assign outputs
always_comb begin : out_mapping
    if(i_encrypt) begin
        for (int column = 0; column < COLUMNS; column++) begin
            for (int line = 0; line < LINES; line++) begin
                if(i_encrypt) begin
                    data_out[0][column] = data_out[0][column] ^ key_ff[NBW_WORD-line*NBW_WORD-:NBW_WORD];
                end else begin
                    data_out[0][column] = data_out[0][column] ^ key_ff[NBW_WORD-line*NBW_WORD-:NBW_WORD];
                end
            end
        end
    end else begin
        for (int column = 0; column < COLUMNS; column++) begin
            for (int line = 0; line < LINES; line++) begin
                if(i_encrypt) begin
                    data_out[0][column] = data_out[0][column] ^ key_ff[NBW_WORD-line*NBW_WORD-:NBW_WORD];
                end else begin
                    data_out[0][column] = data_out[0][column] ^ key_ff[NBW_WORD-line*NBW_WORD-:NBW_WORD];
                end
            end
        end
    end
end

// Map output values from lines x columns to a single dimension
always_comb begin : out_mapping
    if(i_encrypt) begin
        for (int column = 0; column < COLUMNS; column++) begin
            for (int line = 0; line < LINES; line++) begin
                if(i_encrypt) begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end else begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end
            end
        end
    end else begin
        for (int column = 0; column < COLUMNS; column++) begin
            for (int line = 0; line < LINES; line++) begin
                if(i_encrypt) begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end else begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end
            end
        end
    end
end

// Assign outputs
always_comb begin : out_mapping
    if(i_encrypt) begin
        for (int column = 0; column < COLUMNS; column++) begin
            for (int line = 0; line < LINES; line++) begin
                if(i_encrypt) begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end else begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end
            end
        end
    end else begin
        for (int column = 0; column < COLUMNS; column++) begin
            for (int line = 0; line < LINES; line++) begin
                if(i_encrypt) begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end else begin
                    o_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*1:NBW_WORD)] = data_out[line][column];
                end
            end
        end
    end
end