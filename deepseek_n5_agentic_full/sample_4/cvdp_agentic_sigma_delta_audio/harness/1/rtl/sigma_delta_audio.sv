module sigma_delta_audio(
    // Inputs
    input wire [DATA_WIDTH-1:0] load_data_sum,
    input wire [DATA_WIDTH-1:0] read_data_sum,
    input wire clk_sig,
    input wire clk_en_sig,
    // Outputs
    output wire [0:0] left_sig,
    output wire [0:0] right_sig
);

// Internal states and registers
reg [A1_WIDTH-1:0] l_ac1, r_ac1;
reg [A2_WIDTH-1:0] l_ac2, r_ac2;
reg [A1_WIDTH-1:0] l_er0, r_er0;
reg [A1_WIDTH-1:0] l_er0_prev, r_er0_prev;

// Internal wires
wire [A1_WIDTH-1:0] l_adder1, r_adder1;
wire [A1_WIDTH-1:0] l_adder2, r_adder2;
wire [A2_WIDTH-1:0] l_out, r_out;

// LFSR seed constants
parameter seed_1 = 0b10101;
parameter seed_2 = 0b11001;

// Initialize the accumulator states
always initial begin
    l_ac1 = 0;
    r_ac1 = 0;
    l_ac2 = 0;
    r_ac2 = 0;
    l_er0 = 0;
    r_er0 = 0;
    l_er0_prev = 0;
    r_er0_prev = 0;
end

// Dithering generator
function [A1_WIDTH-1:0] s_dither;
    input wire [A1_WIDTH-1:0] s_sum;
    reg seed_1Reg, seed_2Reg;
    
    always @posedge s_sum #2
        if ($0)
            seed_1Reg = seed_1;
            seed_2Reg = seed_2;
        else
            seed_1Reg = (seed_1Reg >> 1) ^ ((seed_1Reg & 1) ? (1 << (A1_WIDTH-1)) : 0);
            seed_2Reg = (seed_2Reg >> 1) ^ ((seed_2Reg & 1) ? (1 << (A1_WIDTH-1)) : 0);
    end
    s_dither = seed_1Reg ^ seed_2Reg;
endfunction

// Accumulator stages
always @posedgeclk_sig #1
begin
    // Left accumulator stage 1
    l_adder1 = (load_data_sum[0] ^ (r_er0 ^ s_dither));
    l_ac1 = l_ac1 + l_adder1;
    l_er0_prev = l_er0;
    l_er0 = (r_ac1 < l_ac1) ? (r_ac1 - l_ac1) : (l_ac1 - r_ac1);

    // Right accumulator stage 1
    r_adder1 = (read_data_sum[0] ^ (r_er0 ^ s_dither));
    r_ac1 = r_ac1 + r_adder1;
    r_er0_prev = r_er0;
    r_er0 = (r_ac1 < r_adder1) ? (r_ac1 - r_adder1) : (r_adder1 - r_ac1);
end

always @posedgeclk_sig #1
begin
    // Left accumulator stage 2
    l_adder2 = (l_er0 ^ l_er0_prev) ? 1 : 0;
    l_ac2 = l_ac2 + l_adder2;
    l_er0 = l_er0 - l_adder2;

    // Right accumulator stage 2
    r_adder2 = (r_er0 ^ r_er0_prev) ? 1 : 0;
    r_ac2 = r_ac2 + r_adder2;
    r_er0 = r_er0 - r_adder2;
end

// Quantization and modulation
always @posedgeclk_sig #1
begin
    // Left channel
    l_out = (l_er0 >= 0) ? 1 : 0;

    // Right channel
    r_out = (r_er0 >= 0) ? 1 : 0;
end

// Final output generation
always @posedgeclk_sig #1
begin
    left_sig = l_out;
    right_sig = r_out;
end

// Reset functionality
always initial begin
    $monitor(reset, "Reset detected");
    if(reset)
        initial begin
            $finish;
            // Initialize all registers to zero
            $val(0);
        end
    end
end