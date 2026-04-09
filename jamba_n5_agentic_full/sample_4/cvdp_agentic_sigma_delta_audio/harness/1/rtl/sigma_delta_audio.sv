module sigma_delta_audio(
    input clk_sig,
    input clk_en_sig,
    input [DATA_WIDTH:0] load_data_sum,
    input [DATA_WIDTH:0] read_data_sum,
    output [DATA_WIDTH:0] left_sig,
    output [DATA_WIDTH:0] right_sig
);

    localparam DATA_WIDTH = 15;
    localparam CLOCK_WIDTH = 2;
    localparam READ_WIDTH = 4;
    localparam A1_WIDTH = 2;
    localparam A2_WIDTH = 5;

    reg [A1_WIDTH:0] l_ac1, r_ac1;
    reg [A2_WIDTH:0] l_ac2, r_ac2;
    reg [DATA_WIDTH:0] l_er0, r_er0;
    reg [A1_WIDTH:0] l_er0_prev, r_er0_prev;
    reg [DATA_WIDTH:0] seed_1, seed_2;
    wire [DATA_WIDTH:0] s_out;
    wire [DATA_WIDTH:0] s_sum;
    wire [DATA_WIDTH:0] left_sig_temp, right_sig_temp;
    wire load_done, read_done;

    always @(posedge clk_sig) begin
        if (clk_en_sig) begin
            // Accumulate samples
            l_ac1 <= l_ac1 + load_data_sum;
            r_ac1 <= r_ac1 + read_data_sum;

            // Error feedback
            l_er0 <= l_er0_prev - l_ac1;
            r_er0 <= r_er0_prev - r_ac1;

            // Accumulate error for next step
            l_ac1 <= l_er0;
            r_ac1 <= l_er0_prev;

            // Dithering with LFSR
            s_out <= seed_1 ^ seed_2;

            // Modulate outputs
            left_sig_temp = l_ac1 + l_er0;
            right_sig_temp = r_ac1 + r_er0;

            // Final outputs
            left_sig <= left_sig_temp >> A1_WIDTH;
            right_sig <= right_sig_temp >> A1_WIDTH;

        end else begin
            left_sig <= 0;
            right_sig <= 0;
        end
    end

endmodule
