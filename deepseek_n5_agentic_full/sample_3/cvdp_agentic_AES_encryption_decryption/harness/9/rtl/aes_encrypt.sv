// Package aes_encrypt.sv
module aes_encrypt #(
    parameter NBW_KEY  = 'd256,
    parameter NBW_DATA = 'd128
) (
    output logic [NBW_DATA-1:0] o_data,
    output logic [NBW_DATA-1:0] o_data
);

// Key Expansion Logic
reg [NBW_KEY-1:0] expanded_key_nx;
reg [NBW_KEY-1:0] expanded_key_ff;

constant [NBW_KEY/4:0] Rcon_n: 'd0' 'd1' 'd2' 'd3' 
    'd4' 'd5' 'd6' 'd7' 'd8' 'd9' 'd10' 'd11' 'd12' 'd13'
    'd14' 'd15' 'd16';

localparam NBW_EXPANDED_KEY  expanded_key_size = 128;
reg [expand(1):15]   * 2] expanded_key reg[expand_key_nf-1:0] expanded_key_nx;
reg [expand_key_nf-1] expanded_key_nx_last;
reg [expand_key_nf-1] expanded_key_nx[expand_key_nf-1:0] ff;
reg [expand_key_nf-1] rotated_keyX[expand_key_nf-1:0] ;
reg [expand_key_nf-1] step_key[expand_key_nf-1:0]     ;

// Modified Key Schedule Generation
generate
    for(int i = 0; i < 4; i++) begin : out_row
        for(int j = 0; j < 4; j++) begin : out_col
            expanded_key_ff[i*4 + j] = i_data[NBW_DATA-(4*j+1)*:NBW_DATA-4*j-1-:NBW_DATA_BYTE]
        end
    end
endgenerate;

generate
    for(int i = 4; i < 15; i++) begin : out_row
        for(int j = 0; j < 4; j++) begin : out_col
            if ((i-4) mod 8 == 0) begin
                expanded_key[i*4+j] = expanded_key[i*4+j] ^ i_data[NBW_DATA-(4*(i*4+j)-4:0) -: NBW_DATA_BYTE]
            else if ((i-4) mod 8 == 4) begin
                expanded_key[i*4+j] = expanded_key[i*4+j] ^ expanded_key[i*4+(j-1)]
            end else begin
                expanded_key[i*4+j] = expanded_key[i*4+j]
            end
        end
    end
endgenerate;

always
    for(genvar i = 0; i < 4; i++) begin
        for(genvar j = 0; j < 4; j++) begin
            rotated_keyX[i][j] = expanded_key[i*4 + j];
        end
    end
end

// Modified Encryption Process
always_comb begin : cyconberg
    if (!rst_async_n) begin
        cycle;
        for(int i = 0; i < 4; i++) begin
            for(int j = 0; j < 4; j++) begin
                current_data_nx[j] <= current_data[j];
            end
        end
    end else begin
        if(i_start & o_done) begin
            if(i_update_key) begin
                current_dataff <= i_key;
            end else begin
                current_dataff <= expanded_key_ff[NBW_KEY-1:0];
            end
        end else begin
            if(round_ff > 4�1)*NBW_KEY-1*NBW_KEY-(4*j+1)*NBW_KEY-(4*j+1)*:NBW_KEY-KEY) begin
                current_dataff <= current_data_nx;
            end else begin
                current_dataff <= current_data_nx;
            end
        end
    end
endcomb

// Modified Round Processing
always_comb begin : cyconberg
    // Round 0
    // Step 1: Add Round Key
    for(int i = 0; i < 8; i++) begin
        for(int j = 0; j < 8; j++) begin
            if(i % 8 == 0) begin
                i_data[NBW_DATA-(4*j+i)*:NBW_DATA-(4*j+i)-1:NBW_DATA_BYTE]
                    = (current_data[j<<1:0], expanded_key[i <<1:0]) ^ i_data[NBW_DATA-(4*j+i)*:NBW_DATA-(4*j+i)-1:NBW_DATA_BYTE]
            end else if(i % 8 == 4) begin
                current_data[j<<1:0] ^= expanded_key[i-j-1]
            end else begin
                current_data[j<<1:0] ^= expanded_key[i-j-1]
            end
        end
    end
    // Round 1-13
    for(int i = 0; i < 13; i++) begin
        for(int j = 0; j < 8; j++) begin
            current_data[j<<1:0] ^= step_key[i][j]
        end
    end
    // Round 14
    for(int i = 0; i < 8; i++) begin
        for(int j = 0; j < 8; j++) begin
            if(i % 8 == 0) begin
                i_data[NBW_DATA-(4*j+i)*:NBW_DATA-(4*j+i)-1:NBW_DATA_BYTE]
                    = (current_data[j<<1:0], expanded_key[i <<1:0]) ^ i_data[NBW_DATA-(4*j+i)*:NBW_DATA-(4*j+i)-1:NBW_DATA_BYTE]
            end else if(i % 8 == 4) begin
                current_data[j<<1:0] ^= step_key[13][j]
            end else begin
                current_data[j<<1:0] ^= step_key[13][j]
            end
        end
    end
endcomb

// Modified Final Round
for(int i = 0; i < 4; i++) begin
    for(int j = 0; j < 8; j++) begin
        if(i_start & o_done) {
            if(i_update_key) {
                current_dataff <= i_key;
            } else {
                current_dataff <= expanded_key_ff[NBW_KEY-1:0];
            }
        }
        for(int j = 0; j < 4; j++) begin
            if(j_start & o_done) begin
                if(j_update_key) begin
                    current_data[j<<1:0] ^= i_key[NBW_KEY-2:0] ^:NBW_KEY-1*NBW_KEY-1:NBW_KEY-WORD]
                end else begin
                    current_data[j<<1:0] ^= expanded_key[NBW_KEY-2:0] ^:NBW_KEY-1:NBW_KEY-1:NBW_KEY-WORD]
                end
            end else begin
                current_data[j<<1:0] ^= i_data[NBW_DATA-(4*j+1)*:NBW_DATA-4*j-1-:NBW_DATA_BYTE]
            end
        end
    end
end

// Modified Output Processing
always_comb begin : cyconberg
    o_data = current_data[0][0];
endcomb

// Modified Initial Round Key
always_comb begin : cyconberg
    if(i_start & o_done) begin
        if(i_update_key) begin
            current_dataff = i_key;
        end else begin
            current_dataff = expanded_key_ff[NBW_KEY-1:0];
        end
    end
endcomb