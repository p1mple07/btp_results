/*
Galois field (2^8) matrix‐based encryption/decryption system using AES’s polynomial to perform galois field operations
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
// - Function for GF(2^8) multiplication by 2
// ----------------------------------------
// This function multiplies an 8-bit value by 2 in GF(2^8).
// If the MSB is 1, the result is reduced by XORing with MOD_POLY.
function automatic logic [7:0] gf_mul2(input logic [7:0] a);
    logic [7:0] result;
    result = a << 1;
    if (a[7])
        result = result ^ MOD_POLY;
    return result;
endfunction

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

logic [NBW_WORD-1:0] data_xtimes2 [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes4 [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes8 [LINES][COLUMNS];

// ----------------------------------------
// - Control registers
// ----------------------------------------
always_ff @(posedge clk or negedge rst_async_n) begin : ctrl_regs
    if (!rst_async_n) begin
        valid_ff <= 0;
        key_ff   <= 0;
    end else begin
        valid_ff[0]         <= i_valid;
        valid_ff[LATENCY:1] <= valid_ff[LATENCY-1:0];
        if(i_update_key) begin
            key_ff <= i_key;
        end
    end
end

// ----------------------------------------
// - Data registers
// ----------------------------------------
always_ff @(posedge clk) begin : data_regs
    for (int line = 0; line < LINES; line++) begin
        for (int column = 0; column < COLUMNS; column++) begin
            if(i_valid) begin
                if(i_encrypt) begin
                    data_in_ff[line][column] <= i_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*COLUMNS)-:NBW_WORD];
                end else begin
                    data_in_ff[line][column] <= i_data[NBW_DATA-1-(column*NBW_WORD + line*NBW_WORD*COLUMNS)-:NBW_WORD] ^ key_ff[NBW_KEY-line*NBW_WORD-1-:NBW_WORD];            
                end
            end

            data_xtimes2_ff[line][column] <= data_xtimes2_nx[line][column];
            data_xtimes3_ff[line][column] <= data_xtimes3_nx[line][column];
            data_xtimes9_ff[line][column] <= data_xtimes9_nx[line][column];
            data_xtimesB_ff[line][column] <= data_xtimesB_nx[line][column];
            data_xtimesD_ff[line][column] <= data_xtimesD_nx[line][column];
            data_xtimesE_ff[line][column] <= data_xtimesE_nx[line][column];

            if(valid_ff[2]) begin
                data_out_ff[line][column] <= data_out_nx[line][column];
            end
        end
    end
end

// ----------------------------------------
// - Intermediary steps
// ----------------------------------------

// Calculate GF(2^8) multiplication by 2, 4 and 8 using the corrected function
always_comb begin : multiply_gf2_4_8
    for (int line = 0; line < LINES; line++) begin
        for (int column = 0; column < COLUMNS; column++) begin
            data_xtimes2[line][column] = gf_mul2(data_in_ff[line][column]);
            data_xtimes4[line][column] = gf_mul2(gf_mul2(data_in_ff[line][column]));
            data_xtimes8[line][column] = gf_mul2(gf_mul2(gf_mul2(data_in_ff[line][column])));
        end
    end
end

// Calculate GF(2^8) multiplications by the values in the polynomial
always_comb begin : multiply_gf
    for (int line = 0; line < LINES; line++) begin
        for (int column = 0; column < COLUMNS; column++) begin
            data_xtimes2_nx[line][column] = data_xtimes2[line][column];
            if(i_encrypt) begin
                data_xt