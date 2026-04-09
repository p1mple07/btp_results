module dbi_enc(
    input wire [39:0] data_in,
    input wire clock,
    input wire rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

    // Initialize previous data to all zeros
    reg [19:0] prev_data1 = 0;
    reg [19:0] prev_data0 = 0;

    // Counters for bit differences
    reg [1:0] bit_diff_count = 0;

    // Calculate bit differences for each group
    integer i;
    for (i = 0; i < 20; i++) begin
        // Compare Group-1 (MSBs)
        if ((data_in[39 - i] != prev_data1[19 - i])) begin
            bit_diff_count[1] += 1;
        end
        // Compare Group-0 (LSBs)
        if ((data_in[i] != prev_data0[i])) begin
            bit_diff_count[0] += 1;
        end
    end

    // Determine control signals based on bit differences
    dbi_cntrl[1] = (bit_diff_count[1] > 10);
    dbi_cntrl[0] = (bit_diff_count[0] > 10);

    // Update previous data for next cycle
    data_out[39:20] = data_in[39:20];
    data_out[19:0] = data_in[19:0];
    prev_data1 = data_out[39:20];
    prev_data0 = data_out[19:0];
endmodule