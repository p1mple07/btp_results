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
    reg [3:0] count;            // Holds the current count value
    reg done;                  // Indicates whether the timer has completed its delay

    always @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            delay <= 0;
            count <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (i_data_in == 1101) begin
                        state <= CONFIGURE_DELAY;
                    end
                end
                CONFIGURE_DELAY: begin
                    delay <= {delay[3:0], i_data_in};
                    state <= COUNTING;
                end
                COUNTING: begin
                    count <= count + 1;
                    if (count == ((delay + 1) * 1000)) begin
                        done <= 1;
                        state <= DONE;
                    end
                end
                DONE: begin
                    if (i_ack) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    assign o_time_left = (done? delay : count[3:0]);
    assign o_processing = (state == COUNTING);
    assign o_completed = done;

endmodule