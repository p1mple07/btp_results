module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising‑edge triggered)
    input wire i_rst_n,         // Active‑low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4‑bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    reg [3:0] delay;            // Holds the 4‑bit delay value
    reg count_phase;            // Accumulated cycles for the counting phase
    reg counting;               // Flag indicating that we are counting
    reg done;                   // Flag that signals the end of the counting phase

    always @(i_clk) begin
        if (i_rst_n) begin
            // Reset all state variables on reset
            o_time_left <= 8'd1000;
            o_processing <= 0;
            o_completed <= 0;
            delay <= 4'd0;
            count_phase <= 0;
            counting <= 0;
            done <= 0;
        end else begin
            if (i_data_in == 4'b1101) begin
                // Detect the start pattern and shift the next 4 bits into delay
                delay <= i_data_in[4:1];
                next_state = CONFIGURE;
            end else if (counting) begin
                count_phase = (delay[3:0] + 1) * 1000;
                if (o_time_left >= count_phase) begin
                    o_completed <= 1;
                    o_processing <= 0;
                end else begin
                    o_time_left <= o_time_left - 1;
                end
            end else if (done) begin
                // Wait for the acknowledgment signal
                if (i_ack) begin
                    o_completed <= 1;
                    o_processing <= 0;
                    o_time_left <= 8'd1000;
                    count_phase <= 0;
                    delay <= 4'd0;
                    next_state = IDLE;
                end else begin
                    next_state = COUNTING;
                end
            end
        end
    end

endmodule
