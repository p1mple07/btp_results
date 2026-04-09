rtl/galois_encryption.sv
/*
Galois field (2^8) matrix‐based encryption/decryption system using AES's polynomial to perform galois field operations
*/

module galois_encryption #(
    parameter NBW_DATA = 'd128,
    parameter NBW_KEY  = 'd32
) (
    input  logic                clk,
    input  logic                rst_async_n,
    input  logic                i_encrypt,
    input  logic                i_valid,
    input  logic [NBW_DATA-1:0] i_data,
    input  logic                i_update_key,
    input  logic [NBW_KEY-1:0]  i_key,
    output logic                o_valid,
    output logic [NBW_DATA-1:0] o_data
);

// ----------------------------------------
// - Internal Parameters
// ----------------------------------------
localparam LATENCY  = 'd3;
localparam NBW_WORD = 'd8;
localparam MOD_POLY = 8'h1B;
localparam LINES    = 'd4;
localparam COLUMNS  = 'd4;

// ----------------------------------------
// - Wires/Registers creation
// ----------------------------------------
logic [LATENCY:0]    valid_ff;
logic [NBW_KEY-1:0]  key_ff;
logic [NBW_WORD-1:0] data_in_ff      [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes2_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes3_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes9_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimesB_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimesD_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimesE_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_out_nx     [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes2_ff [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes3_ff [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes9_ff [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimesB_ff [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimesD_ff [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimesE_ff [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_out_ff     [LINES][COLUMNS];

logic [NBW_WORD-1:0] data_xtimes