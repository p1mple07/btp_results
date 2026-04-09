module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // State definitions for the FSM
    localparam STATE_IDLE      = 2'd0;
    localparam STATE_CONFIGURE = 2'd1;
    localparam STATE_COUNTING  = 2'd2;
    localparam STATE_DONE      = 2'd3;

    // Constant for 1000 clock cycles (14-bit wide to cover up to 16000 cycles)
    localparam COUNT_THRESHOLD = 14'd1000;

    // Internal registers
    reg [1:0] state;                  // FSM state register
    reg [3:0] pattern_reg;            // Shift register for detecting the 1101 start sequence
    reg [1:0] config_bit_count;       // Counter for the 4 configuration bits
    reg [3:0] delay;                  // Delay value configured (most significant bit first)
    reg [13:0] cycle_count;           // Cycle counter for the counting phase
    reg [3:0] decrement_count;        // Counter to track how many 1000-cycle segments have elapsed
    reg [13:0] total_cycles;          // Total cycles for the counting phase = (delay + 1) * 1000

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state            <= STATE_IDLE;
            pattern_reg      <= 4'd0;
            config_bit_count <= 2'd0;
            delay            <= 4'd0;
            cycle_count      <= 14'd0;
            decrement_count  <= 4'd0;
            total_cycles     <= 14'd0;
            o_processing     <= 1'b0;
            o_time_left      <= 4'd0;
            o_completed      <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    // Shift in the serial data for start sequence detection
                    pattern_reg <= {pattern_reg[2:0], i_data_in};
                    if (pattern_reg == 4'b1101) begin
                        state <= STATE_CONFIGURE;
                        // Optionally clear pattern_reg here if desired
                    end
                    o_processing <= 1'b0;
                    o_completed  <= 1'b0;
                    o_time_left  <= 4'd0;  // Don't-care in idle state
                end

                STATE_CONFIGURE: begin
                    // Shift in the next 4 bits to configure the delay (MSB first)
                    if (config_bit_count < 2'd3) begin
                        delay          <= {delay[2:0], i_data_in};
                        config_bit_count <= config_bit_count + 1;
                    end else begin
                        // Last configuration bit received; calculate total counting cycles
                        total_cycles   <= (delay + 1) * COUNT_THRESHOLD;
                        cycle_count    <= 14'd0;
                        decrement_count<= 4'd0;
                        state          <= STATE_COUNTING;
                        config_bit_count <= 2'd0;  // Reset configuration bit counter
                    end
                    o_processing <= 1'b0;
                    o_completed  <= 1'b0;
                    o_time_left  <= 4'd0;
                end

                STATE_COUNTING: begin
                    // Increment the cycle counter each clock cycle
                    cycle_count <= cycle_count + 1;
                    // Every 1000 cycles, increment the decrement counter
                    if (cycle_count == COUNT_THRESHOLD - 1)
                        decrement_count <= decrement_count + 1;
                    // Transition to DONE state when the total cycle count is reached
                    if (cycle_count == total_cycles - 1)
                        state <= STATE_DONE;
                    
                    o_processing <= 1'b1;
                    // o_time_left decrements every 1000 cycles:
                    // For the first 1000 cycles, o_time_left = delay;
                    // Then it decrements by 1 every subsequent 1000 cycles, clamped to 0.
                    if (delay > decrement_count)
                        o_time_left <= delay - decrement_count;
                    else
                        o_time_left <= 4'd0;
                    o_completed  <= 1'b0;
                end

                STATE_DONE: begin
                    o_completed  <= 1'b1;
                    o_processing <= 1'b0;
                    // Wait for the acknowledgment signal to reset the module
                    if (i_ack) begin
                        state            <= STATE_IDLE;
                        cycle_count      <= 14'd0;
                        decrement_count  <= 4'd0;
                        delay            <= 4'd0;
                        total_cycles     <= 14'd0;
                        config_bit_count <= 2'd0;
                        pattern_reg      <= 4'd0;
                    end
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule