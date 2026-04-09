module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // Internal signals and registers
    reg [3:0] state;             // Current state of the FSM
    reg [3:0] count;              // Counter for the number of clock cycles
    reg [3:0] delay;              // Holds the 4-bit delay value
    reg [3:0] time_left;         // Remaining time left in the timer
    wire done;                   // Asserted high when the timer completes its delay

    // Define the FSM states
    enum {IDLE, CONFIGURE_DELAY, COUNTING, DONE} state_enum;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
            count <= 0;
            delay <= 0;
            time_left <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (i_data_in == 8'b1101) begin
                        state <= CONFIGURE_DELAY;
                    end
                end
                CONFIGURE_DELAY: begin
                    delay <= i_data_in[3:0];
                    state <= COUNTING;
                end
                COUNTING: begin
                    count <= count + 1;
                    if (count == ((delay + 1) * 1000)) begin
                        time_left <= delay;
                        state <= DONE;
                    end
                end
                DONE: begin
                    if (i_ack) begin
                        state <= IDLE;
                        done <= 1;
                    end
                end
            endcase
        end
    end

    assign o_processing = (state == COUNTING);
    assign o_time_left = time_left;
    assign o_completed = done;

endmodule