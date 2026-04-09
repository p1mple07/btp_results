module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // Internal registers
    reg [3:0] delay;            // Holds the 4-bit delay value
    reg [3:0] time_left;        // Holds the remaining time for counting
    reg processing;              // Asserted high when the timer is actively counting
    reg completed;               // Asserted high when the timer completes its delay
    reg done;                     // Asserted high when all delays have been completed

    always @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            delay <= 0;
            time_left <= 0;
            processing <= 0;
            completed <= 0;
            done <= 0;
        end else begin
            if (i_data_in == 11'b1101) begin
                delay <= i_data_in[3:0];
                time_left <= delay * 1000;
                processing <= 1;
                completed <= 0;
                done <= 0;
            end else if (processing &&!done) begin
                time_left <= time_left - 1;
                if (time_left == 0) begin
                    done <= 1;
                end
            end
        end
    end

    assign o_time_left = time_left;
    assign o_processing = processing;
    assign o_completed = completed;

endmodule