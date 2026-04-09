module that increments on a CPU trigger (cpu_trig_i)
 * and provides its value on a software read (sw_req_i). When sw_req_i is asserted,
 * the counter’s current value is captured and then the counter resets to zero on
 * the following cycle. The counter width is parameterizable.
 *
 * Timing details:
 * - All registers are positive edge-triggered with an asynchronous reset.
 * - The counter increments on cpu_trig_i unless a software read occurred in the previous cycle.
 * - When sw_req_i is high, the output (p_count_o) shows the current counter value;
 *   otherwise, p_count_o remains zero.
 */

module cvdp_copilot_perf_counters #(
    parameter CNT_W = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic sw_req_i,
    input  logic cpu_trig_i,
    output logic [CNT_W-1:0] p_count_o
);

    // Internal registers
    logic [CNT_W-1:0] count_q;       // The main counter register
    logic [CNT_W-1:0] perf_out;      // Register to capture the counter value for output
    logic sw_req_prev;               // To detect a software read from the previous cycle

    // Counter logic:
    // - On reset, count_q is set to 0.
    // - On each clock, if a software read occurred in the previous cycle (sw_req_prev),
    //   then count_q is reset to 0.
    // - Otherwise, if cpu_trig_i is asserted, count_q is incremented.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count_q     <= '0;
            sw_req_prev <= '0;
        end else begin
            // Check for a previous software read: if so, reset the counter.
            if (sw_req_prev)
                count_q <= '0;
            // Else, if the CPU trigger is active, increment the counter.
            else if (cpu_trig_i)
                count_q <= count_q + 1;
            
            // Update the sw_req_prev register with the current sw_req_i.
            sw_req_prev <= sw_req_i;
        end
    end

    // Output logic:
    // - When sw_req_i is asserted, capture the current counter value into perf_out.
    // - Otherwise, drive perf_out to zero.
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            perf_out <= '0;
        else begin
            if (sw_req_i)
                perf_out <= count_q;
            else
                perf_out <= '0;
        end
    end

    // Drive the performance counter output.
    assign p_count_o = perf_out;

endmodule