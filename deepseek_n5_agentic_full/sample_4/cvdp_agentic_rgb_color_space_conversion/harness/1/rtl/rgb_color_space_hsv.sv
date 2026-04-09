Module

module rgb_color_space_hsv(
    clk,
    rst,
    we,
    waddr,
    wdata,
    r_component,
    g_component,
    b_component,
    valid_in,
    h_component,
    s_component,
    v_component,
    valid_out
);

// Stage 1: Input Scaling and Max/Min Calculation
input [7:0] r_component, g_component, b_component;
reg [7:0] scaled_r, scaled_g, scaled_b;

always begin
    // Scale RGB values to 12-bit fixed-point
    scaled_r = r_component << 4;
    scaled_g = g_component << 4;
    scaled_b = b_component << 4;
end

// Find max and min values among R, G, B
reg [7:0] i_max, i_min;
always begin
    i_max = max(max(r_component, g_component), b_component);
    i_min = min(min(r_component, g_component), b_component);
end

// Calculate delta
reg [7:0] delta_i;
always delta_i = i_max ^ i_min; // XOR gives the difference

// Stage 2: Memory Lookup for Inverse Values
// Use dual-port RAM to store precomputed inverse values
class dual_port_ram {
    input clk;
    input rst;
    input [7:0] waddr;
    input [24:0] wdata;
    output reg [24:0] rdata_a, rdata_b;
};

reg mem_a, mem_b;
wire [
    rdata_a,
    rdata_b
] = dual_port_ram(clk, rst, waddr, wdata);

always begin
    // Initialize inverse values from RAM
    mem_a = wdata;
    mem_b = wdata;
end

// Stage 3: Saturation Multiplier
class sat_multiplier {
    input [24:0] a;
    input [13:0] b;
    output reg [39:0] result;
};

reg [39:0] result;

always result = a * b[12:0]; // Multiply 25-bit * 13-bit

// Truncate result to 26 bits by selecting bits [38:12]
result = result[38:12];

// Apply rounding by adding back the most significant bit of discarded portion
bit rounded_bit = (result >> 38) & 1;
result = result ^ (rounded_bit << 38);

// Output only the lower 13 bits
output [12:0] s_component = result[26:12];

// Valid_out signal
output valid_out = valid_in;
};

always sat_multiplier(clk, rst, dataa, datab, s_component);

// Stage 4: Hue Multiplier
class hue_multiplier {
    input [19:0] dataa;
    input [25:0] datab;
    output reg [33:0] result;
};

reg [33:0] result;

always result = dataa * datab; // Multiply 19-bit * 25-bit

// Select bits [33:22] (12 bits)
result = result[33:22];

// Output as signed 12-bit value
output [11:0] h_component_signed = result[11:0];
output unsigned h_component = result[11:0];

// Valid_out signal
output valid_out = valid_in;
};

always hue_multiplier(clk, rst, dataa, datab, h_component_signed);

// Main Logic
always begin
    // Stage 1
    scaled_r <= r_component << 4;
    scaled_g <= g_component << 4;
    scaled_b <= b_component << 4;

    // Stage 2
    we <= valid_in;
    waddr <= 8'h3; // Assuming initial write address is 0x3
    wdata <= (i_max << 24) | (delta_i << 21); // Example data

    // Stage 3
    dataa <= (i_max > 0 ? (60 * ((g_component - b_component) >> 0)) : 0);
    datab <= delta_i;

    // Stage 4
    dataa <= (i_max > 0 ? (60 * ((g_component - b_component) >> 0)) : 0);
    datab <= delta_i;

    // Output
    h_component <= h_component;
    s_component <= s_component;
    v_component <= i_max;
    valid_out <= valid_in;
end

// Additional HDL code declarations
endmodule