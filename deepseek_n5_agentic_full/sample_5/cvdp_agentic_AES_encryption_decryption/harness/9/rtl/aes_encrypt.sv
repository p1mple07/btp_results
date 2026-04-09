module aes_encrypt (
    parameter NBW_KEY  = 'd256,
    parameter NBW_DATA = 'd128;
    register [NBW_KEY-1:0]  i_key,
    register [NBW_KEY-1:0]  key schedule
);
 
    localparam Rcon  NBW_KEY= 'd10,
    localparam Rcon  NBW_KEY= 'd11,
    localparam Rcon  NBW_KEY= 'd12,
    localparam Rcon  NBW_KEY= 'd13,
    localparam Rcon  NBW_KEY= 'd14,
    localparam Rcon  NBW_KEY= 'd15',
    localparam Rcon  NBW_KEY= 'd16',
    localparam Rcon  NBW_KEY= 'd17',
    localparam Rcon  NBW_KEY= 'd18,
    localparam Rcon  NBW_KEY= 'd19,
    localparam Rcon  NBW_KEY= 'd1a,
    localparam Rcon  NBW_KEY= 'd1b,
    localparam Rcon  NBW_KEY= 'd1c,
    localparam Rcon  NBW_KEY= 'd1d,
    localparam Rcon  NBW_KEY= 'd1e,
    localparam Rcon  NBW_KEY= 'd1f;

    generate
        for genvar i = 0; i < 14; i++) begin : expand
            for genvar j = 0; j < 4; j++) begin : expAND
                localparam [NBW_KEY-1:0] ExpandedKey[i][j] = Rcon[nibble2((4*j)+i)];
                localparam [NBW_KEY-1:0] SubBytes[i][j]     = byteonumber(RotWord[ikey]);
                localparam [NBW_KEY-1:0] AddRoundKey[i][j]  = byteonumber(SubBytes[i][j]);
            end
        end
    endgenerate;

    always_comb begin : cypher_logic
        for(int i = 0; i < 15; i++) begin : out_row
            for(int j = 0; j < 4; j++) begin : col
                if(i_start & o_done || (round AffineRound[i-1]*NBW_KEY-1-4&1-1&1)begin
                    round_affine[i] <= round affine[i-1];
                    round_affine[i] <= round_affine[i-1] ^ 1'b1;
                end else begin
                    round_affine[i] <= round_affine[i-1];
                end
            end
        end
    endalways_comb;

    always_comb begin : add_round_key
        for(int i = 0; i < 15; i++) begin : round
            for(int j = 0; j < int(sizeof_key)/8; j++) begin : col
                if(j_start & o_done) begin
                    if(i_update_key) begin
                        valid_key &= !o_done;
                    end else begin
                        valid_key &= expanded_key_nx[i][j], NBW_KEY-1:0-: NBW_KEY-KEY;
                    end
                end else begin
                    if(i_update_key) begin
                        valid_key &= !o_done;
                    end else begin
                        valid_key &= expanded_key_nx[i][j], NBW_KEY-KEY-1:0-: NBW_KEY-KEY;
                    end
                end
            end
        end
    endalways_comb;

    always_comb begin : next_data
        for(int i = 0; i < 4; i++) begin : row
            for(int j = 0; j < 4; j++) begin : col
                sbox[uu_sbox0 (
                    .i_data(i_key[4*j+0-:4*j+4-1-:4*j+4_byte]),
                    .o_data(next_o_data)
                )];
            end
        end
    endalways_comb;
endgenerate;

always_comb begin : cypher_logic
    // Initial data
    // Load into Sboxes
    if(!rst_async_n) begin
        round_affine[0] <= 8'h38;
        round_affine[0] <= 8'h42;
        round_affine[0] <= 8'h4c;
        round_affine[0] <= 8'h4b;
        round_affine[0] <= 8'hf1;
        round_affine[0] <= 8'h1b;
        round_affine[0] <= 8'h2b;
        round_affine[0] <= 8'h32;
    end
endalways_comb;