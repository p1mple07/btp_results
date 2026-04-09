module dbi_enc(
    input wire [39:0] data_in,
    input wire clock,
    input wire rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

    // Previous data storage
    reg [19:0] prev_group1, prev_group0;

    // Control signals
    reg [1:0] control1, control0;

    // Bit counters
    reg [19:0] bit_count1, bit_count0;

    // Initialize previous data on first clock cycle
    always_ff (clk, rst_n) prev_group1, prev_group0;

    // Split data into groups
    wire [19:0] group1, group0;
    group1 = data_in[39:20];
    group0 = data_in[19:0];

    // Compare with previous data
    integer i;
    always clocked(clk) begin
        if (rst_n) begin
            prev_group1 = 0;
            prev_group0 = 0;
            bit_count1 = 0;
            bit_count0 = 0;
        end else begin
            // Compare group1
            for (i = 0; i < 20; i++) begin
                if ((group1[i] != prev_group1[i])) bit_count1++;
            end
            control1 = (bit_count1 > 10);

            // Compare group0
            for (i = 0; i < 20; i++) begin
                if ((group0[i] != prev_group0[i])) bit_count0++;
            end
            control0 = (bit_count0 > 10);
        end
    end

    // Generate data_out
    data_out = 0;
    data_out[39:20] = (control1 ? (group1 ^ 1) : group1);
    data_out[19:0] = (control0 ? (group0 ^ 1) : group0);
endmodule