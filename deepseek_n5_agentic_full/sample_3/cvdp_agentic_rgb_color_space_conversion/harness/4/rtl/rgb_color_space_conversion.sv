<<<<<<< SEARCH
    // Output reg          valid_out
=======
    // Output reg          valid_out
    // CMYK Outputs
    reg [16:0] cmyk_channel_c, cmyk_channel_m, cmyk_channel_y, cmyk_channel_k;

    // Additional outputs for CMYK calculations
    reg [12:0] cmyk_intermediate_a, cmyk_intermediate_b;
>>>>>>> REPLACE

<<<<<<< SEARCH
    output reg          valid_out
=======
    output reg          valid_out
    output reg [16:0] cmyk_channel_c, cmyk_channel_m, cmyk_channel_y, cmyk_channel_k;
>>>>>>> REPLACE

<<<<<<< SEARCH
    reg signed [11:0] i_max, i_min, stage1_max, stage1_min, stage1_b;
=======
    reg signed [11:0] i_max, i_min, stage1_max, stage1_min, stage1_b;
    reg signed [12:0] cmyk_intermediate_a, cmyk_intermediate_b;
>>>>>>> REPLACE

<<<<<<< SEARCH
module rgb_color_space_conversion (
    input               clk,
    input               rst,

    // Memory ports to initialize (1/delta) values
    input               we,
    input       [7:0]   waddr,
    input      [24:0]   wdata,

    // Input data with valid.
    input               valid_in,
    input       [7:0]   r_component,
    input       [7:0]   g_component,
    input       [7:0]   b_component,

    // HSV Output values
    output reg [11:0]   hsv_channel_h,  // Output in fx10.2 format, degree value = (hsv_channel_h)/4
    output reg [12:0]   hsv_channel_s,  // Output in fx1.12 format. % value = (hsv_channel_s/4096)*100
    output reg [11:0]   hsv_channel_v,  // % value = (hsv_channel_v/255) * 100

    // HSL Output values
    output reg [11:0]   hsl_channel_h,  // Output in fx10.2 format, degree value = (hsl_channel_h)/4
    output reg [12:0]   hsl_channel_s,  // Output in fx1.12 format. % value = (hsl_channel_s/4096)*100
    output reg [11:0]   hsl_channel_l,  // % value = (hsl_channel_l/255) * 100

    output reg          valid_out
=======
module rgb_color_space_conversion (
    input               clk,
    input               rst,

    // Memory ports to initialize (1/delta) values
    input               we,
    input       [7:0]   waddr,
    input      [24:0]   wdata,

    // Input data with valid.
    input               valid_in,
    input       [7:0]   r_component,
    input       [7:0]   g_component,
    input       [7:0]   b_component,

    // HSV Output values
    output reg [11:0]   hsv_channel_h,  // Output in fx10.2 format, degree value = (hsv_channel_h)/4
    output reg [12:0]   hsv_channel_s,  // Output in fx1.12 format. % value = (hsv_channel_s/4096)*100
    output reg [11:0]   hsv_channel_v,  // % value = (hsv_channel_v/255) * 100

    // HSL Output values
    output reg [11:0]   hsl_channel_h,  // Output in fx10.2 format, degree value = (hsl_channel_h)/4
    output reg [12:0]   hsl_channel_s,  // Output in fx1.12 format. % value = (hsl_channel_s/4096)*100
    output reg [11:0]   hsl_channel_l,  // % value = (hsl_channel_l/255) * 100

    // CMYK Output values
    output reg [16:0]   cmyk_channel_c,  // Cyan component in fx8.8 format.
    output reg [16:0]   cmyk_channel_m,  // Magenta component in fx8.8 format.
    output reg [16:0]   cmyk_channel_y,  // Yellow component in fx8.8 format.
    output reg [8:0]    cmyk_channel_k; // Black (Key) component in Integer format.

    output reg          valid_out
>>>>>>> REPLACE