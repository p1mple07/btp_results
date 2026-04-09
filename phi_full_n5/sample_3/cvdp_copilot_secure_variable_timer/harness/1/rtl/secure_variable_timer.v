
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
    reg [9:0] counter;          // Counter for the total cycle count
    reg [3:0] time_left;        // Temporary register to hold the current time left

    // State definitions
    typedef enum logic [1:0] {IDLE, CONFIGURE, COUNTING, DONE} State_t;
    reg [1:0] state, next_state;

    // State transition logic
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
            counter <= 0;
            time_left <= 0;
        end else begin
            state <= next_state;
        end
    end

    // State machine logic
    always @(state or i_data_in or i_ack) begin
        case (state)
            IDLE: begin
                if (i_data_in == 4'b1101) begin
                    delay <= i_data_in;
                    next_state = CONFIGURE;
                end else begin
                    next_state = IDLE;
                end
            end
            CONFIGURE: begin
                if (i_data_in == 4'b0000) begin
                    next_state = COUNTING;
                end else begin
                    next_state = IDLE;
                end
            end
            COUNTING: begin
                counter <= counter + 1;
                if (counter >= delay + 999) begin
                    counter <= 0;
                    time_left <= delay;
                    o_time_left <= time_left;
                    o_processing <= 1'b1;
                    next_state = DONE;
                end else begin
                    time_left <= time_left - 1;
                    o_time_left <= time_left;
                end
            end
            DONE: begin
                if (i_ack) begin
                    o_completed <= 1'b1;
                    next_state = IDLE;
                end else begin
                    next_state = IDLE;
                end
            end
        end
    end

endmodule

