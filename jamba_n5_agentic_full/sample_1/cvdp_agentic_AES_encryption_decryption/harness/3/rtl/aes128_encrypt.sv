`timescale 1ns / 1ps

module aes128_encrypt #(
    parameter NBW_KEY  = 'd128,
    parameter NBW_DATA = 'd128
) (
    input  logic                clk,
    input  logic                rst_async_n,
    input  logic                i_update_key,
    input  logic [NBW_KEY-1:0]  i_key,
    input  logic                i_start,
    input  logic [NBW_DATA-1:0] i_data,
    output logic                o_done,
    output logic [NBW_DATA-1:0] o_data
);

localparam NBW_BYTE   = 'd8;
localparam STEPS      = 'd10;
localparam NBW_WORD   = 'd32;
localparam NBW_EX_KEY = 'd1408;

logic [NBW_BYTE-1:0]   Rcon   [STEPS];
logic [NBW_KEY-1:0]    valid_key;
logic [NBW_KEY-1:0]    step_key[STEPS];
logic [NBW_EX_KEY-1:0] expanded_key_nx;
logic [NBW_EX_KEY-1:0] expanded_key_ff;
logic [NBW_BYTE-1:0]   current_data_nx[4][4];
logic [NBW_BYTE-1:0]   current_data_ff[4][4];
logic [NBW_BYTE-1:0]   SubBytes[4][4];
logic [NBW_BYTE-1:0]   ShiftRows[4][4];
logic [NBW_BYTE-1:0]   xtimes02[4][4];
logic [NBW_BYTE-1:0]   xtimes03[4][4];
logic [NBW_BYTE-1:0]   MixColumns[4][4];
logic [3:0] round_ff;

// Initialise RON values
Rcon[0] = 8'h01;
Rcon[1] = 8'h02;
Rcon[2] = 8'h04;
Rcon[3] = 8'h08;
Rcon[4] = 8'h10;
Rcon[5] = 8'h20;
Rcon[6] = 8'h40;
Rcon[7] = 8'h80;
Rcon[8] = 8'h1b;
Rcon[9] = 8'h36;

// Generate round keys
always_ff @(posedge clk or negedge rst_async_n) begin : generate_round_keys
    step_key_ff[0] = expanded_key_ff[0];
    for (int i = 1; i < STEPS; i++) begin
        step_key_ff[i] = step_key_ff[i-1] ^ Rcon[i];
    end
end

// Main encryption logic
always_comb begin : next_data
    for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < 4; j++) begin
            if (i_start & o_done || (round_ff > 4'd0 && round_ff < 4'd11)) begin
                round_ff <= round_ff + 1'b1;
            end else begin
                round_ff <= 4'd0;
            end

            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    if (i_start & o_done) begin
                        current_data_nx[i][j] = i_data[NBW_DATA-(4*j+i)*NBW_BYTE-1-:NBW_BYTE] ^ expanded_key_ff[NBW_EX_KEY-(4*j+i)*NBW_BYTE-1-:NBW_BYTE];
                    end else begin
                        if (round_ff > 4'd1) begin
                            current_data_nx[i][j] = ShiftRows[i][j] + expanded_key_ff[NBW_EX_KEY-(round_ff-1)*NBW_KEY-(4*j+i)*NBW_BYTE-1-:NBW_Byte];
                        end else begin
                            current_data_nx[i][j] = current_data_ff[i][j];
                        end
                    end
                end
            end
        end
    end
end

// ... rest of the code unchanged ...
