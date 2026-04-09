module dbi_enc(
    input wire [39:0] data_in,
    input clock,
    input rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

    // Initialize previous data with zeros
    reg [39:0] prev_data = 40'h00000000;

    // Split data into two 20-bit groups
    reg [19:0] prev_group0;
    reg [19:0] prev_group1;

    // Counters for differences
    reg [19:0] count0, count1;

    // XOR gates for comparison
    wire [19:0] xor0, xor1;

    // Full adders for summing differences
    adder0 sum0;
    adder1 sum1;

    // Control signals
    reg [1:0] control;

    // Logic to generate data_out
    reg [39:0] inverted_group0, inverted_group1;

    // Clock enable signals
    wire clock enable0, enable1;

    // Initialize flip-flops on first clock cycle after reset
    always @*+ clock, rst_n) begin
        prev_data = 40'h00000000;
        prev_group0 = 20'h00000000;
        prev_group1 = 20'h00000000;
        count0 = 20'h00000000;
        count1 = 20'h00000000;
        xor0 = 20'h00000000;
        xor1 = 20'h00000000;
        enable0 = 0;
        enable1 = 0;
    end

    // Split data into groups
    always @*+ clock, rst_n) begin
        prev_data = data_out;
        prev_group0 = (data_in >> 20) & 20'h00000000;
        prev_group1 = data_in & 20'h00000000;

        // Compare with previous data
        xor0 = (prev_group0 ^ data_in) & 20'h00000000;
        xor1 = (prev_group1 ^ data_in) & 20'h00000000;

        // Count differences
        count0 = count0 + xor0;
        count1 = count1 + xor1;

        // Determine control signals
        control[1] = (count1 > 10);
        control[0] = (count0 > 10);

        // Invert groups if needed
        if (control[1]) {
            inverted_group1 = ~prev_group1;
        } else {
            inverted_group1 = prev_group1;
        }

        if (control[0]) {
            inverted_group0 = ~prev_group0;
        } else {
            inverted_group0 = prev_group0;
        }

        // Generate data_out
        data_out = (inverted_group1 << 20) | inverted_group0;
    end
endmodule