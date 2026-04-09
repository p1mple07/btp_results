module key_expansion_128aes #(
    parameter NBW_KEY = 'd128,
    parameter NBW_OUT = 'd1408
) (
    input  logic               clk,
    input  logic               rst_async_n,
    input  logic [NBW_KEY-1:0] i_key,
    output logic [NBW_OUT-1:0] o_expanded_key,
    output logic [NBW_OUT-1:0] o_expanded_key_nx,

    // Auxiliary wires
    logic [NBW_KEY-1:0] valid_key;
    logic [NBW_KEY-1:0] step_key[STEPS];
    logic [NBW_KEY-1:0] expanded_key_nx;
    logic [NBW_KEY-1:0] expanded_key_ff;

    // Auxiliary registers
    register
        NBW_KEY valid_key_reg;
    register
        NBW_KEY step_key_reg[STEPS];
    register
        NBW_KEY expanded_key_nx_reg;
    register
        NBW_KEY expanded_key_ff_reg;
);

localparam NBW_BYTE = 'd8;
localparam STEPS = 'd10;
localparam NBW_WORD = 'd32;

// Auxiliary wires
logic [NBW_WORD-1:0] RotWord;
logic [NBW_WORD-1:0] SubWord;
logic [NBW_WORD-1:0] RconXor;

// Register initialization
always_comb begin : reset_regs
    if (~rst_async_n) begin
        expanded_key_ff <= {NBW_OUT{1'b0}};
        step_key_reg <= expanded_key_nx;
        if (i_start || (|expanded_key_nx[9:0])) begin
            expanded_key_nx <= expanded_key_ff;
        end else begin
            expanded_key_nx <= expanded_key_nx;
        end
    end else begin
        expanded_key_ff <= expanded_key_nx;
        if (i_start || (|expanded_key_nx[9:0])) begin
            expanded_key_nx <= expanded_key_ff;
        end else begin
            expanded_key_nx <= expanded_key_nx;
        end
    end
end

always_comb begin : generate_steps
    for(genvar i = 0; i < STEPS; i++) begin : steps
        logic [NBW_WORD-1:0] RotWord = {expanded_key_nx[NBW_BYTE:0]};
        logic [NBW_WORD-1:0] SubWord = {expanded_key_nx[NBW_BYTE:0]};
        always_comb begin
            RotWord = {SubWord[31:24]^Rcon[i], SubWord[23:16], SubWord[15:8], SubWord[7:0]};
            RconXor = SubWord ^ {Rcon[i] ^ SubWord[0]};
            step_key[i][127:96] = expanded_key_nx[NBW_WORD-1:NBW_WORD-1-3];
            step_key[i][95 : 64] = expanded_key_nx[NBW_WORD-1:NBW_WORD-1-4];
            step_key[i][63 : 32] = expanded_key_nx[NBW_WORD-1:NBW_WORD-1-5];
            step_key[i][31 : 0] = expanded_key_nx[NBW_WORD-1:NBW_WORD-1-6];
        end
    end
end

always_comb begin : assign_o
    o_expanded_key = expanded_key_nx;
    o_expanded_key_nx = expanded_key_ff;
end

always_comb begin : reset_regs
    if (rst_async_n) begin
        expanded_key_nx <= {NBW_OUT{1'b0}};
        step_key_reg <= expanded_key_nx;
        if (i_start || (|expanded_key_nx[9:0])) begin
            expanded_key_nx <= expanded_key_nx;
        end else begin
            expanded_key_nx <= expanded_key_nx;
        end
    end else begin
        expanded_key_nx <= expanded_key_nx;
        if (i_start || (|expanded_key_nx[9:0])) begin
            expanded_key_nx <= expanded_key_nx;
        end else begin
            expanded_key_nx <= expanded_key_nx;
        end
    end
end

generate
    for(genvar i = 0; i < STEPS; i++) begin : steps
        logic [NBW_WORD-1:0] RotWord;
        logic [NBW_WORD-1:0] SubWord;
        logic [NBW_WORD-1:0] RconXor;

        RotWord = {expanded_key_nx[NBW_BYTE:0]};
        SubWord = {expanded_key_nx[NBW_BYTE:0]};
        RconXor = SubWord ^ {Rcon[i] ^ SubWord[0]};
    end
endgenerate

always_comb begin
    if (i_start || (|expanded_key_nx[9:0])) begin
        expanded_key_ff <= expanded_key_nx;
    end else begin
        expanded_key_ff <= expanded_key_nx;
    end
end

endmodule