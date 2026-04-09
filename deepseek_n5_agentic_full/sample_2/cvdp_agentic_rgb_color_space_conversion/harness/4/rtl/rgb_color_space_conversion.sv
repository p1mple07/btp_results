// New output ports for CMYK channels
output reg [16:0] cmyk_channel_c, cmyk_channel_m, cmyk_channel_y;
output reg [8:0] cmyk_channel_k;

// Registers for CMYK calculations
reg signed [16:0] cm_yreg1, cm_yreg2, cm_yreg3;

// Stage 2: Calculate CMY components
always @(posedge clk or posedge rst) begin
    if (valid_in) begin
        // Cyan (C)
        cm_yreg1 = (i_max_shreg[2] - r_sub_g_shreg[2]);
        // Magenta (M)
        cm_yreg2 = (i_max_shreg[2] - g_sub_b_shreg[2]);
        // Yellow (Y)
        cm_yreg3 = (i_max_shreg[2] - b_sub_r_shreg[2]);
        
        // Scale and saturate to 12-bit fixed-point
        cmyk_channel_c <= (cm_yreg1 >> 8) + 12;  // fx8.8 format
        cmyk_channel_m <= (cm_yreg2 >> 8) + 12;
        cmyk_channel_y <= (cm_yreg3 >> 8) + 12;
        
        // Black (K) component
        cmyk_channel_k <= i_max_shreg[2];
    end
end

// Ensure CMYK outputs are valid in sync with valid_out
always @(posedge valid_out) begin
    // Ensure CMYK outputs are cleared on reset
    if (rst) begin
        cmyk_channel_c <= 0;
        cmyk_channel_m <= 0;
        cmyk_channel_y <= 0;
        cmyk_channel_k <= 0;
    end
end