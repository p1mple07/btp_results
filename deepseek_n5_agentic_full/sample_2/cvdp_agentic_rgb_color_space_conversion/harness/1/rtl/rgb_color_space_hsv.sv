Module

module rgb_color_space_hsv(
    input               clk,
    input               rst,
    
    input               we,
    input       [7:0]   waddr,
    input      [24:0]   wdata,
    
    input               valid_in,
    input       [7:0]   r_component,
    input       [7:0]   g_component,
    input       [7:0]   b_component,

    output reg [11:0]   h_component,  // Output in fx10.2 format, For actual degree value = (h_component)/4
    output reg [12:0]   s_component,  // Output in fx1.12 format. For actual % value = (s_component/4096)*100
    output reg [11:0]   v_component,  // For actual % value = (v_component/255) * 100
    output reg          valid_out
);

// Calculate maximum and minimum values among R, G, B components
reg [7:0] i_max, i_min;
assign 
    i_max = max(max(r_component, g_component), b_component);
    i_min = min(min(r_component, g_component), b_component);
    delta_i = i_max - i_min;

// Determine the maximum component and compute delta
reg [7:0] dataa, datab;
always @* begin
    case (i_max)
        8'b111 -> dataa = r_component;
        8'b101 -> dataa = g_component;
        8'b100 -> dataa = b_component;
        default: dataa = 0;
    endcase
    
    datab = delta_i;
end

// Compute hue value based on maximum component
reg [31:0] temp;
always @* begin
    case (i_max)
        8'b111 | 8'b101 -> h = 60 * ((g_component - b_component) >> 7) + 60 * ((g_component - b_component) >> 6 & 1);
        8'b111 | 8'b100 -> h = 60 * ((b_component - r_component) >> 7) + 120 * ((b_component - r_component) >> 6 & 1);
        8'b101 | 8'b100 -> h = 60 * ((r_component - g_component) >> 7) + 240 * ((r_component - g_component) >> 6 & 1);
        default: h = 0;
    endcase
    // Truncate and round
    h_component = (h >> 2);
end

// Compute saturation
reg [39:0] product;
always @* begin
    product = s_component * (delta_i >> 24);
    // Truncate and round
    s_component = (product >> 12);
end

// Compute value
v_component = i_max;

// Assertion of valid_output
valid_out = 1;
always @posedge valid_in or posedge rst begin
    if (rst) valid_out = 0;
    else if (!valid_in) valid_out = 0;
    else valid_out = 1;
end

// Placeholder for dual-port RAM implementation
// Note: This code does not include the RAM implementation as per the specification
// It assumes the existence of precomputed inverse values stored in dual-port RAM
// This is part of the higher-level system design and not part of the core functionality

endmodule