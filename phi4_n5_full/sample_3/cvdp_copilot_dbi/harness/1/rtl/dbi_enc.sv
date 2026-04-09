module dbi_enc (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [39:0]  data_in,
    output logic [39:0]  data_out,
    output logic [1:0]   dbi_cntrl
);

    // Register to hold the previous 40-bit data word
    logic [39:0] prev_data;

    // Split current data into two 20-bit groups
    // Group-1: Most Significant 20 bits
    // Group-0: Least Significant 20 bits
    logic [19:0] curr_group1;
    logic [19:0] curr_group0;

    // Counters for bit differences between current and previous groups
    // (Using $countones which returns an integer value)
    integer diff_count1, diff_count0;

    // Synchronous process: on clock edge or asynchronous reset
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset: clear previous data and outputs
            prev_data    <= 40'b0;
            data_out     <= 40'b0;
            dbi_cntrl    <= 2'b00;
        end else begin
            // Split the incoming 40-bit data into two 20-bit groups
            curr_group1 = data_in[39:20];
            curr_group0 = data_in[19:0];

            // Calculate the number of bit differences for each group compared to previous data
            diff_count1 = $countones(curr_group1 ^ prev_data[39:20]);
            diff_count0 = $countones(curr_group0 ^ prev_data[19:0]);

            // Determine control signals:
            // If more than 10 bits differ, set the corresponding control bit high (1)
            dbi_cntrl[1] = (diff_count1 > 10);
            dbi_cntrl[0] = (diff_count0 > 10);

            // Generate output data based on control signals:
            // If control bit is high, invert the corresponding group; otherwise, pass-through unchanged.
            if (dbi_cntrl[1])
                data_out[39:20] = ~curr_group1;
            else
                data_out[39:20] = curr_group1;

            if (dbi_cntrl[0])
                data_out[19:0] = ~curr_group0;
            else
                data_out[19:0] = curr_group0;

            // Update previous data with the current cycle's data_out for next comparison
            prev_data <= data_out;
        end
    end

endmodule