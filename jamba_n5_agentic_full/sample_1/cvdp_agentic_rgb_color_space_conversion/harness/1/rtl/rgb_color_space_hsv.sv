// rtl/rgb_color_space_hsv.sv
`timescale 1ns / 1ps

module rgb_color_space_hsv (
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

    // Internal signals for the dual-port RAM stages
    reg [31:0] i_max, i_min, delta_i;
    reg [18:0] data_a, data_b, data_c;
    reg [1:0] stage;

    // Stage 0: Wait for the reset and initial write enable
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i_max <= 0;
            i_min <= 0;
            delta_i <= 0;
            data_a <= 0;
            data_b <= 0;
            data_c <= 0;
            stage <= 0;
        end else begin
            case (stage)
                0: begin
                    // Stage 0: Wait for write enable
                    stage <= 1;
                end
                1: begin
                    // Stage 1: Read the RGB values
                    if (valid_in) begin
                        r_component <= wdata[7];
                        g_component <= wdata[6];
                        b_component <= wdata[5];
                    end
                    stage <= 2;
                end
                2: begin
                    // Stage 2: Compute max, min, and delta
                    if (r_component > g_component && r_component > b_component)
                        i_max <= r_component;
                    else if (g_component > r_component && g_component > b_component)
                        i_max <= g_component;
                    else
                        i_max <= b_component;
                    
                    if (r_component < g_component && r_component < b_component)
                        i_min <= r_component;
                    else if (g_component < r_component && g_component < b_component)
                        i_min <= g_component;
                    else
                        i_min <= b_component;
                    
                    delta_i <= i_max - i_min;
                    stage <= 3;
                end
                3: begin
                    // Stage 3: Store inverse of i_max
                    data_a <= ~i_max;
                    stage <= 4;
                end
                4: begin
                    // Stage 4: Store inverse of delta_i
                    data_b <= ~delta_i;
                    stage <= 5;
                end
                5: begin
                    // Stage 5: Perform saturation calculation
                    s_component <= data_b / data_a;  // Fixed‑point division via multiplication
                    stage <= 6;
                end
                6: begin
                    // Stage 6: Compute hue
                    h_component <= 60 * ((g_component - b_component) / delta_i) + 60 * ((b_component - r_component) / delta_i) + 60 * ((r_component - g_component) / delta_i);
                    stage <= 7;
                end
                7: begin
                    // Stage 7: Finalise value
                    v_component <= i_max;
                    stage <= 8;
                end
                8: begin
                    // Stage 8: Output ready
                    valid_out = 1;
                end
            endcase
        end
    end

endmodule
