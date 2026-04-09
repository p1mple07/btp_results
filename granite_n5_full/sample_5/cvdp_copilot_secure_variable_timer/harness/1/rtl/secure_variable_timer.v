module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // Constants
    localparam COUNT_CYCLES = 7000;
    
    // Registers
    reg [3:0] delay;            // Holds the 4-bit delay value
    reg [3:0] time_left;       // Remaining time during counting phase
    reg [3:0] counter;          // Counter for COUNT_CYCLES
    reg processing;             // Asserted high when the timer is actively counting
    reg completed;              // Asserted high when the timer completes its delay

   // FSM states
    typedef enum logic [1:0] {
        IDLE, CONFIGURE_DELAY, COUNTING, DONE
    } fsm_state_t;
    fsm_state_t state;

   // Always block for synchronous reset
   always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            delay <= 0;
            time_left <= COUNT_CYCLES;
            counter <= 0;
            processing <= 0;
            completed <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (i_data_in == 1101) begin
                        state <= CONFIGURE_DELAY;
                    end
                end
                CONFIGURE_DELAY: begin
                    delay <= {delay[3:0], i_data_in};
                    time_left <= COUNT_CYCLES;
                    state <= COUNTING;
                end
                COUNTING: begin
                    counter <= counter + 1;
                    time_left <= time_left - 1;
                    if (counter == COUNT_CYCLES) begin
                        state <= DONE;
                    end
                end
                DONE: begin
                    completed <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

   // Outputs during counting
   assign o_time_left = time_left;
   assign o_processing = processing;
   assign o_completed = completed;

   // Reset behavior
   always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
        end
   end

endmodule