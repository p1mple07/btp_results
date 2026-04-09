module rgb_color_space_hsv(
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

    // Output values
    output reg [11:0]   h_component,  // Output in fx10.2 format, For actual degree value = (h_component)/4
    output reg [12:0]   s_component,  // Output in fx1.12 format. For actual % value = (s_component/4096)*100
    output reg [11:0]   v_component,  // For actual % value = (v_component/255) * 100
    output reg          valid_out
);

    // Local variables
    reg [38:0] data_a, data_b;
    reg [33:0] data_c;
    reg [38:0] intermediate;
    reg [7:0] i_max, i_min;
    reg delta_i;
    reg h_val, s_val, v_val;

    initial begin
        // Wait, we need to implement the algorithm.
    end

endmodule
