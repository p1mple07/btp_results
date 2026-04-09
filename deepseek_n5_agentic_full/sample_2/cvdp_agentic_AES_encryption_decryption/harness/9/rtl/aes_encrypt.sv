module aes_encrypt (
    parameter NBW_KEY  = 'd256,
    parameter NBW_DATA = 'd128
);

// Inside the module, modify the key schedule generation section:

// 1. Update key expansion:
alwaysvar NBW_WORD  expanded_key_nx [
    0 .. 79
] : expanded_key_nx = 8'd0;

reg var NBW_WORD  expanded_key_nf [
    3:0
]    : expanded_key_nf;
reg var NBW_WORD  expanded_key_ff [
    3:0
]    : expanded_key_ff;

logic [NBW_KEY-1:0]  key_part[8..11-:1b0]    := 8'h1000;
localparam RESteps      = 'd10;
localparam STP_KEY      = 'd10;
localparam NBW_WORD   = 'd32;
localparam NBW_KEY     = 'd256;
localparam NBW_DATA    = 'd128;
localparam NBW_CIPHER  = 'd128;
localparam NBW_DATA    = 'd128;

// Initialize expanded_key_nx and expanded_key_nf
always init : resetregs
    if(!rst_async_n) begin
        expanded_key_nx = {NBW_KEY{1'b0}, NBW_KEY{1'b1}, 8'd0, 8'd0,
            8'h1000, 8'h2000, 8'h4000, 8'h8000, 8'h1000, 8'h2000, 
            8'h4000, 8'h8000, 8'h1000, 8'h2000, 8'h4000, 8'h8000,
            8'h1000, 8'h2000, 8'h4000, 8'h8000, 8'h1000, 8'h2000,
            8'h4000, 8'h8000, 8'h1000, 8'h2000, 8'h4000, 8'h8000,
            8'h1000, 8'h2000, 8'h4000, 8'h8000, 8'h1000, 8'h2000,
            8'h4000, 8'h8000, 8'h1000, 8'h2000, 8'h4000, 8'h8000,
            8'h1000, 8'h2000, 8'h4000, 8'h8000, 8'h1000, 8'h2000,
            8'h4000, 8'h8000, 8'h1000, 8'h2000, 8'h4000, 8'h8000,
            8'h1000, 8'h2000, 8'h4000, 8'h8000, 8'h1000, 8'h2000,
            8'h4000, 8'h8000, 8'h1000, 8'h2000, 8'h4000, 8'h8000,
            8'h1000, 8'h2000, 8'h4000, 8'h8000, 8'h1000, 8'h2000,
            8'h4000, 8'h8000 };
    end else begin
        expanded_key_nx = expanded_key_nf;
    end

always genvar i;
always var i;
always genvar j;
always var j;
always genvar k;
always var k;

reg var NBW_WORD  RegFFExpandedKey_nx [
    0 .. 79
]    : RegFFExpandedKey_nx;
reg var NBW_WORD  RegFFExpandedKey_nf [
    3:0
]    : RegFFExpandedKey_nf;
reg var NBW_WORD  RegFFExpandedKey_ff [
    3:0
]    : RegFFExpandedKey_ff;
reg var NBW_WORD  expanded_key_nf[
    3:0
]     : expanded_key_nf;

// Modified key schedule generation for AES-256
always_comb begin : start_data
    for(j = 0; j < 80; j++) begin : out_reg
        i = j;
        if(j / 8) % 2 == 0 || (j / 8 - 1) % 2 == 0) begin
            wait 4'd0;
            temp_ff = 8'h1B;
            i--[0:0] := 8'h01;
        end else begin
            temp_ff := 8'h00;
        end
        if(j % 8 == 0 && j != 0) begin
            temp_ff := 8'h01;
            j--[0:0] := 8'h01;
            X := SubByte[i];
        end else if(j % 8 == 4) begin
            X := SubByte[i];
        end else begin
            X := i;
        end
        i--[0:0] := X;
        temp--[0:0] := tempff;
        expanded_key_nx[i][j] := {temp--[0:0:0], expanded_key_nx[i][j-1:0]};
    end
end

// ... rest of the module remains unchanged ...