module that inverts data groups based on the number
 * of bit differences with the previous data.
 *
 * The 40-bit input data is split into two 20-bit groups:
 *   - Group-1: data_in[39:20]
 *   - Group-0: data_in[19:0]
 *
 * For each group, the number of bit differences compared to the previous cycle's
 * corresponding group (stored in prev_data) is counted. If more than 10 bits differ,
 * the corresponding control bit is set (1), and the data is inverted; otherwise, it
 * remains unchanged.
 *
 * On reset (rst_n low), all outputs and the stored previous data are reset to 0.
 */

module dbi_enc (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [39:0]  data_in,
    output logic [39:0]  data_out,
    output logic [1:0]   dbi_cntrl
);

    // Register to store previous data_out for comparison
    logic [39:0] prev_data;

    // Internal signals for the two 20-bit groups
    logic [19:0] group1, group0;
    logic [19:0] out_group1, out_group0;

    // Counters for bit differences (max value 20, so 5 bits are sufficient)
    logic [4:0] diff1_count, diff0_count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset: clear all registers
            prev_data      <= 40'b0;
            data_out       <= 40'b0;
            dbi_cntrl      <= 2'b00;
        end else begin
            // Split the 40-bit input into two 20-bit groups
            group1 = data_in[39:20];
            group0 = data_in[19:0];

            // Initialize difference counters
            diff1_count = 5'b0;
            diff0_count = 5'b0;

            // Count the number of bit differences between current groups and previous data
            for (int i = 0; i < 20; i++) begin
                diff1_count += (group1[i] !== prev_data[39:20][i]);
                diff0_count += (group0[i] !== prev_data[19:0][i]);
            end

            // Determine output groups: invert if more than 10 bits differ
            out_group1 = (diff1_count > 5'd10) ? ~group1 : group1;
            out_group0 = (diff0_count > 5'd10) ? ~group0 : group0;

            // Combine groups to form data_out
            data_out  <= {out_group1, out_group0};

            // Set control bits: bit1 for group1, bit0 for group0
            dbi_cntrl <= { (diff1_count > 5'd10), (diff0_count > 5'd10) };

            // Update previous data with current data_out for next cycle comparison
            prev_data <= data_out;
        end
    end

endmodule