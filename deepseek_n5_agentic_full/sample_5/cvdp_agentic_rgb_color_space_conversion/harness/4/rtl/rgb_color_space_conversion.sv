// ... [Previous contents remain unchanged until the end of the file]
 
// New CMYK Channel Outputs
output reg [15:0] cmyk_channel_c, cmyk_channel_m, cmyk_channel_y;
output reg [7:0] cmyk_channel_k;

// CMYK Output Validation
output reg valid_cmyk;

// Internal CMYK Logic Control
wire [7:0] cmk_sel control;
 
// CMYK Calculation Stages
always @(posedgeclk or posedge rst) begin
    if (!valid_in) begin
        cmyk_channel_c <= 0;
        cmyk_channel_m <= 0;
        cmyk_channel_y <= 0;
        cmyk_channel_k <= 0;
        valid_cmyk <= 0;
        continue;
    end
    // Calculate Cyan (cmyk_channel_c)
    // Cyan = max(R, G) - G
    unsigned_diff_r_g <= (r_component - g_component);
    unsigned_diff_g_r <= (g_component - r_component);
    unsigned max_rg <= max(unsigned_diff_r_g, unsigned_diff_g_r);
    unsigned max_rg_minus_g <= max_rg - g_component;
    cmyk_channel_c <= max_rg_minus_g;
    // Calculate Magenta (cmyk_channel_m)
    // Magenta = max(G, B) - B
    unsigned_diff_g_b <= (g_component - b_component);
    unsigned_diff_b_g <= (b_component - g_component);
    unsigned max_gb <= max(unsigned_diff_g_b, unsigned_diff_b_g);
    unsigned max_gb_minus_b <= max_gb - b_component;
    cmyk_channel_m <= max_gb_minus_b;
    // Calculate Yellow (cmyk_channel_y)
    // Yellow = max(B, R) - R
    unsigned_diff_b_r <= (b_component - r_component);
    unsigned_diff_r_b <= (r_component - b_component);
    unsigned max_br <= max(unsigned_diff_b_r, unsigned_diff_r_b);
    unsigned max_br_minus_r <= max_br - r_component;
    cmyk_channel_y <= max_br_minus_r;
    // Calculate Black (cmyk_channel_k)
    // Black = 255 - max(R, G, B)
    unsigned max_rgb <= max(r_component, g_component, b_component);
    cmyk_channel_k <= (255 - max_rgb);
    // Update Validity
    valid_cmyk <= valid_out;
end
 
// New CMYK Output Buffers
// ... [Existing code continues]