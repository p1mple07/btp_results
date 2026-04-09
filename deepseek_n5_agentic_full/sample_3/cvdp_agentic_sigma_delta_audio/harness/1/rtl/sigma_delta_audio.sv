Module: sigma_delta_audio
module sigma_delta_audio(
    // Inputs
    input wire [DATA_WIDTH-1:0] left_sig,
    input wire [DATA_WIDTH-1:0] right_sig,
    input wire [DATA_WIDTH-1:0] left_load,
    input wire [DATA_WIDTH-1:0] right_load,
    input wire [CLOCK_WIDTH-1:0]clk_sig,
    input wire [1:0]clk_en_sig,

    // Outputs
    output wire [0] left_output,
    output wire [0] right_output,

    // Internal signals
    reg [A1_WIDTH-1:0] l_ac1,
    reg [A1_WIDTH-1:0] r_ac1,
    reg [A2_WIDTH-1:0] l_ac2,
    reg [A2_WIDTH-1:0] r_ac2,
    reg [1:0] l_er0,
    reg [1:0] r_er0,
    reg [1:0] l_er0_prev,
    reg [1:0] r_er0_prev,
    reg [1:0] s_out,
    reg [1:0] seed_1,
    reg [1:0] seed_2,
    reg [1:0] load_data_sum,
    reg [1:0] read_data_sum,
    reg [1:0] quant_l,
    reg [1:0] quant_r,
    reg [1:0] output_sign_left,
    reg [1:0] output_sign_right,

    // Constants
    parameter DATA_WIDTH = 15,
    parameter CLOCK_WIDTH = 2,
    parameter READ_WIDTH = 4,
    parameter A1_WIDTH = 2,
    parameter A2_WIDTH = 5

);

always_comb begin
    // Load data on positive edge of clock
    positive_edge(clk_sig) begin
        // Initialize all registers to 0
        l_ac1 <= 0;
        r_ac1 <= 0;
        l_ac2 <= 0;
        r_ac2 <= 0;
        l_er0 <= 0;
        r_er0 <= 0;
        l_er0_prev <= 0;
        r_er0_prev <= 0;
        s_out <= 0;
        seed_1 <= 0;
        seed_2 <= 0;

        // Accumulate input data
        l_ac1 <= l_ac1 + left_load;
        r_ac1 <= r_ac1 + right_load;

        // Apply dithering and quantization
        s_out <= s_out ^ ((seed_1 << 1) ^ seed_2);
        seed_1 <= (seed_1 << 1) | (s_out & 1);
        seed_2 <= (seed_2 << 1) | (s_out >> 1 & 1);

        // Compute error feedback
        l_er0 <= l_er0 + (l_ac1 - l_ac2) * (l_ac1 > l_ac2);
        r_er0 <= r_er0 + (r_ac1 - r_ac2) * (r_ac1 > r_ac2);

        // Update previous error values
        l_er0_prev <= l_er0;
        r_er0_prev <= r_er0;

        // Generate output signals
        quant_l <= (l_er0 >= 0) ? 1 : 0;
        quant_r <= (r_er0 >= 0) ? 1 : 0;

        // Determine output signs
        output_sign_left <= (quant_l == 0) ? ~(l_er0 > 0) : (l_er0 < 0);
        output_sign_right <= (quant_r == 0) ? ~(r_er0 > 0) : (r_er0 < 0);

        // Final output signals
        left_output <= output_sign_left;
        right_output <= output_sign_right;
    end
endmodule