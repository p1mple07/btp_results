module key_expansion_128aes #(
    parameter NBW_KEY = 'd128,
    parameter NBW_OUT = 'd1408
) (
    input  logic               clk,
    input  logic               rst_async_n,
    input  logic [NBW_KEY-1:0] i_key,
    output logic [NBW_OUT-1:0] o_expanded_key
);

localparam NBW_BYTE = 'd8;
localparam STEPS = 'd10;
localparam NBW_WORD = 'd32;

// Auxiliary wires
logic [NBW_WORD-1:0] Rcon   [STEPS];
logic [NBW_WORD-1:0] STEPSx;
logic [NBW_WORD-1:0] RotWord;
logic [NBW_WORD-1:0] SubWord;
logic [NBW_WORD-1:0] RconXor;

// Module-level variables
logic [NBW_WORD-1:0] valid_key;
logic [NBW_WORD-1:0] step_key[STEPS];
logic [NBW_WORD-1:0] expanded_key_nx;
logic [NBW_WORD-1:0] expanded_key_ff;

always_comb begin : reset_regs
    if (~rst_async_n) begin
        expanded_key_ff <= {NBW_OUT{1'b0}};
        steps_ff <= 11'h400;
    end else begin
        expanded_key_ff <= expanded_key_nx;
        if (i_start || (|steps_ff[9:0])) begin
            expanded_key_nx = {valid_key  , step_key[0], step_key[1], step_key[2],
                              step_key[3], step_key[4], step_key[5], step_key[6],
                              step_key[7], step_key[8], step_key[9]};
        end else begin
            expanded_key_nx = expanded_key_ff;
        end
    end
end

always_comb begin : reset_regs
    if (~rst_async_n) begin
        Rcon[0] = 8'h01;
        Rcon[1] = 8'h02;
        Rcon[2] = 8'h04;
        Rcon[3] = 8'h08;
        Rcon[4] = 8'h10;
        Rcon[5] = 8'h20;
        Rcon[6] = 8'h40;
        Rcon[7] = 8'h80;
        Rcon[8] = 8'h1b;
        Rcon[9] = 8'h2b;
    end
end

always_comb begin : reset_regs
    RotWord = {expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD:NBW_OUT-i*NBW_KEY-NBW_WORD], expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_BYTE]};
    SubWord = {expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_BYTE]};
    RconXor = {SubWord[31:24]^Rcon[i], SubWord[23:0]};

    step_key[i][127:96] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ RconXor;
    step_key[i][95 :64] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ step_key[i][127:96];
    step_key[i][63 :32] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ step_key[i][95:64];
    step_key[i][31 :0] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ step_key[i][63:32];
end

always_comb begin : reset_regs
    o_done = steps_ff[STEPS:0];
end

generate
    for(i = 0; i < STEPS; i++) begin : steps
        if (i_start || (|steps_ff[9:0])) begin
            if (i % 4 == 0) begin
                RotWord = {expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD:NBW_OUT-i*NBW_KEY-NBW_WORD], expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_BYTE]};
                SubWord = {expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_BYTE]};
                RconXor = {SubWord[31:24]^Rcon[i], SubWord[23:0]};

                step_key[i][127:96] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ RconXor;
                step_key[i][95 :64] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ step_key[i][127:96];
                step_key[i][63 :32] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ step_key[i][95:64];
                step_key[i][31 :0] = expanded_key_ff[NBW_OUT-(i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-i*NBW_KEY-NBW_WORD] ^ step_key[i][63:32];
            end else begin
                step_key[i][127:96] = step_key[i-1][127:96] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
                step_key[i][95 :64] = step_key[i-1][95:64] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
                step_key[i][63 :32] = step_key[i-1][63:32] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
                step_key[i][31 :0] = step_key[i-1][31:0] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
            end
        end else begin
            step_key[i][127:96] = step_key[i-1][127:96] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
            step_key[i][95 :64] = step_key[i-1][95:64] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
            step_key[i][63 :32] = step_key[i-1][63:32] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
            step_key[i][31 :0] = step_key[i-1][31:0] ^ expanded_key_ff[NBW_OUT-(4*i+1)*NBW_KEY+NBW_WORD-1:NBW_OUT-(4*i)*NBW_KEY-NBW_WORD];
        end
    end
endgenerate

always_comb begin : reset_regs
    expanded_key_nx = {valid_key  , step_key[0], step_key[1], step_key[2],
                          step_key[3], step_key[4], step_key[5], step_key[6],
                          step_key[7], step_key[8], step_key[9]};
end

always_comb begin : reset_regs
    o_done = steps_ff[STEPS:0];
end

endmodule