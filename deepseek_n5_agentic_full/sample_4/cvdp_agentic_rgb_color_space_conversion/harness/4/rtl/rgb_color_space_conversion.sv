module rgb_color_space_conversion (
    input               clk,
    input               rst,
    
    // RGB inputs with valid.
    input               valid_in,
    input               r_component,
    input               g_component,
    input               b_component,

    // HSV Outputs
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
    output reg [8:0]    cmyk_channel_k,  // Black (Key) component in Integer format.

    // HSV Output validity
    output reg          valid_out
);

    // Additional input ports for control signals and valid/incoming data
    input               we,
    input               waddr,
    input               wdata,

    // Internal processing nodes...

    // New CMYK Calculation Section
    // 1/delta_i from multi_port_ram
    reg signed [25:0] inv_i_max,
    reg signed [25:0] inv_delta_i,
    reg signed [25:0] hsl_inv_denom;

    // Use existing multi_port_ram for 1/delta_i
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inv_i_max <= 0;
            inv_delta_i <= 0;
            hsl_inv_denom <= 0;
        end else begin
            inv_i_max <= inv_i_max_reg;
            inv_delta_i <= inv_delta_i_reg;
            hsl_inv_denom <= hsl_inv_denom_reg;
        end
    end

    // CMYK Calculations
    // Calculate CMY components using fixed-point arithmetic
    // Implement equations per CMYK specification
    // ... Add additional logic for CMYK calculations ...

    // Connect CMYK outputs to the new ports
    assign cmyk_channel_c = cmc_output;
    assign cmyk_channel_m = mcm_output;
    assign cmyk_channel_y = ysm_output;
    assign cmyk_channel_k = klm_output;

    // Update valid_out connection to match CMYK output timing requirements
    assign valid_out = valid_hsv_out;