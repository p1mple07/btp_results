// ... existing code ...

module aes128_encrypt #(
    parameter NBW_KEY  = 'd128,
    parameter NBW_DATA = 'd128
)
    localparam KEYenc    = 'd18;
    localparam SUBenc    = 'd1408;

    wire [NBW_KEY-1:0] KEYex    = KEYenc;
    wire [KEYenc-1:0]    SUBex    = SUBenc;

    register signed [NBW_KEY-1:0] NBW_Ndx;
    register signed [NBW_KEY-1:0] NBW_Sub;

    // Corrected key schedule generation logic...