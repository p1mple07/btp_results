
generate
    for(genvar i = 0; i < STEPS; i++) begin : steps
        logic [NBW_WORD-1:0] RotWord;
        logic [NBW_WORD-1:0] SubWord;
        logic [NBW_WORD-1:0] RconXor;

        sbox uu_sbox0 (
            .i_data(RotWord[31:24]),
            .o_data(SubWord[31:24])
        );

        sbox uu_sbox1 (
            .i_data(RotWord[23:16]),
            .o_data(SubWord[23:16])
        );

        sbox uu_sbox2 (
            .i_data(RotWord[15:8]),
            .o_data(SubWord[15:8])
        );

        sbox uu_sbox3 (
            .i_data(RotWord[7:0]),
            .o_data(SubWord[7:0])
        );

        always_comb begin
            RotWord = {expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-NBW_BYTE-1-:(NBW_WORD-NBW_BYTE)], expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1-:NBW_BYTE]};
            RconXor = {SubWord[31:24]^Rcon[i], SubWord[23:0]};

            step_key[i][127:96] = expanded_key_ff[NBW_OUT-(4*i  )*NBW_WORD-1-:NBW_WORD] ^ RconXor;
            step_key[i][95 :64] = expanded_key_ff[NBW_OUT-(4*i+1)*NBW_WORD-1-:NBW_WORD] ^ step_key[i][127:96];
            step_key[i][63 :32] = expanded_key_ff[NBW_OUT-(4*i+2)*NBW_WORD-1-:NBW_WORD] ^ step_key[i][95 :64];
            step_key[i][31 :0 ] = expanded_key_ff[NBW_OUT-(4*i+3)*NBW_WORD-1-:NBW_WORD] ^ step_key[i][63 :32];
        end
    end
endgenerate
