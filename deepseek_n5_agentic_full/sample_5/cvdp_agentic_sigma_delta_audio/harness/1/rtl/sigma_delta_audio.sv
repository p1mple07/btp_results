module rtl/sigma_delta_audio (
    // Inputs
    input wire [CLOCK_WIDTH - 1:0] clk_sig,
    input wire [1:0] clk_en_sig,
    input wire [DATA_WIDTH - 1:0] load_data_sum,
    input wire [DATA_WIDTH - 1:0] read_data_sum,
    // Outputs
    output [0:0] left_sig,
    output [0:0] right_sig
);

// Internal registers
reg [A1_WIDTH - 1:0] l_ac1, r_ac1;
reg [A1_WIDTH - 1:0] l_ac2, r_ac2;
reg [A2_WIDTH - 1:0] l_er0, r_er0;

// Initialize all registers to 0
initial begin
    l_ac1 = 0;
    r_ac1 = 0;
    l_ac2 = 0;
    r_ac2 = 0;
    l_er0 = 0;
    r_er0 = 0;
end

// LFSR seeds (to be initialized appropriately)
reg seed_1, seed_2;

// Function to generate dithering signal
function [1:0] s_out;
    integer i;
    // Assume proper initialization of seed_1 and seed_2
    seed_1 = 0b1010;
    seed_2 = 0b1001;
    repeat (i, 8) begin
        s_out = (seed_1 >> 1) ^ (seed_2 >> 1);
        seed_1 = (seed_1 << 1) ^ ((seed_1 >> 12) & 1);
        seed_2 = (seed_2 << 1) ^ ((seed_2 >> 12) & 1);
    end
endfunction

// Always block describing the sigma delta modulator
always_ff @* begin
    // Load new data
    l_ac1 <= l_ac1 + (load_data_sum[7:8]);
    r_ac1 <= r_ac1 + (read_data_sum[7:8]);

    // Accumulate data
    l_ac2 <= l_ac2 + (l_ac1 >> 15);
    r_ac2 <= r_ac2 + (r_ac1 >> 15);

    // Compute error
    l_er0 = l_ac2 & ~ (2'b00);
    r_er0 = r_ac2 & ~ (2'b00);

    // Apply dithering
    l_er0 = l_er0 ^ s_out;
    r_er0 = r_er0 ^ s_out;

    // Quantize and produce output
    if (l_er0) begin
        left_sig = 1'b1;
    else
        left_sig = 1'b0;
    end

    if (r_er0) begin
        right_sig = 1'b1;
    else
        right_sig = 1'b0;
    end
end

endmodule