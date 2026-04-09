module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    //-------------------------------------------------------------------------
    // State Encoding
    //-------------------------------------------------------------------------
    localparam IDLE      = 2'b00;
    localparam CONFIG    = 2'b01;
    localparam COUNT     = 2'b10;
    localparam WAIT_ACK  = 2'b11;

    //-------------------------------------------------------------------------
    // Internal Registers
    //-------------------------------------------------------------------------
    reg [1:0] state;
    reg [3:0] pattern_shift; // Shift register for detecting the 1101 start pattern
    reg [3:0] config_reg;    // Shift register for reading the 4-bit delay value
    reg [1:0] config_count;  // Counts the number of bits received in CONFIG state
    reg [3:0] delay;         // Delay value configured from serial input
    reg [9:0] cycle_counter; // 10-bit counter for cycles within a 1000-cycle interval
    reg [3:0] interval;      // 4-bit counter for completed 1000-cycle intervals

    //-------------------------------------------------------------------------
    // Main FSM Process
    //-------------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Synchronous reset: return to idle state and clear registers
            state            <= IDLE;
            pattern_shift    <= 4'b0;
            config_reg       <= 4'b0;
            config_count     <= 2'b0;
            delay            <= 4'b0;
            cycle_counter    <= 10'b0;
            interval         <= 4'b0;
            o_time_left      <= 4'b0;
            o_processing     <= 1'b0;
            o_completed      <= 1'b0;
        end else begin
            case (state)
                //----------------------------------------------------------------
                // IDLE State: Search for the 1101 start pattern
                //----------------------------------------------------------------
                IDLE: begin
                    // Shift in the serial bit; most significant bit comes in first.
                    pattern_shift <= {pattern_shift[2:0], i_data_in};
                    // When the pattern 1101 is detected, move to CONFIG state.
                    if (pattern_shift == 4'b1101)
                        state <= CONFIG;
                    else
                        state <= IDLE;
                    
                    // In idle, outputs are not valid.
                    o_processing <= 1'b0;
                    o_completed  <= 1'b0;
                    o_time_left  <= 4'b0; // Don't care (set to 0)
                end

                //----------------------------------------------------------------
                // CONFIG State: Read the next 4 bits to configure the delay.
                //----------------------------------------------------------------
                CONFIG: begin
                    // Shift in the next 4 bits (MSB first) to form the delay value.
                    config_reg <= {config_reg[2:0], i_data_in};
                    config_count <= config_count + 1;
                    // Once 4 bits have been received...
                    if (config_count == 2'b11) begin
                        delay            <= config_reg;
                        state            <= COUNT;
                        config_count     <= 2'b0;     // Reset configuration counter
                        interval         <= 4'b0;     // Initialize interval counter
                        cycle_counter    <= 10'b0;    // Initialize cycle counter
                        o_time_left      <= delay;    // Start with full delay value
                    end
                    o_processing <= 1'b0;
                    o_completed  <= 1'b0;
                    o_time_left  <= 4'b0; // Not valid in CONFIG phase
                end

                //----------------------------------------------------------------
                // COUNT State: Count for ((delay + 1) * 1000) clock cycles.
                // The counting is divided into intervals of 1000 cycles.
                //----------------------------------------------------------------
                COUNT: begin
                    o_processing <= 1'b1; // Timer is actively counting
                    cycle_counter <= cycle_counter + 1;
                    
                    // When one 1000-cycle interval is complete...
                    if (cycle_counter == 10'd999) begin
                        // Calculate total intervals = delay + 1.
                        // We count intervals from 0 to (delay+1)-1.
                        if (interval == (delay + 1) - 1) begin
                            // Final interval reached; complete counting.
                            state <= WAIT_ACK;
                        end else begin
                            // Increment interval and update remaining time.
                            interval <= interval + 1;
                            o_time_left <= delay - interval;
                        end
                    end
                    o_completed <= 1'b0;
                end

                //----------------------------------------------------------------
                // WAIT_ACK State: Wait for the acknowledgment signal to reset.
                //----------------------------------------------------------------
                WAIT_ACK: begin
                    o_completed <= 1'b1; // Notify that counting is complete
                    // Wait until the acknowledgment (i_ack) is asserted.
                    if (i_ack)
                        state <= IDLE;
                    o_processing <= 1'b0;
                    o_time_left  <= 4'b0;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule