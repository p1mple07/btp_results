module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // Define FSM states
    localparam IDLE     = 2'b00,
               CONFIG   = 2'b01,
               COUNT    = 2'b10,
               DONE     = 2'b11;

    // Internal registers
    reg [1:0] state;           // FSM state register
    reg [3:0] shift_reg;       // 4-bit shift register for detecting the "1101" start sequence
    reg [3:0] delay_reg;       // 4-bit register to hold the delay value (configured after "1101")
    reg [1:0] config_counter;  // Counter for reading 4 bits in CONFIG state
    reg [9:0] cycle_counter;   // 10-bit counter to count within each 1000-cycle block
    reg [3:0] block_counter;   // Counts how many 1000-cycle blocks have elapsed

    // FSM and main logic
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state          <= IDLE;
            shift_reg      <= 4'b0000;
            config_counter <= 0;
            cycle_counter  <= 0;
            block_counter  <= 0;
            delay_reg      <= 4'b0000;
            o_processing   <= 0;
            o_completed    <= 0;
            o_time_left    <= 4'b0000;
        end else begin
            case (state)
                IDLE: begin
                    // In IDLE, shift in i_data_in to detect the "1101" start sequence.
                    shift_reg <= {shift_reg[2:0], i_data_in};
                    if (shift_reg == 4'b1101) begin
                        state <= CONFIG;
                    end
                end

                CONFIG: begin
                    // In CONFIG state, read the next 4 bits (MSB first) to configure the delay.
                    if (config_counter < 4) begin
                        // Shift right: the first bit received becomes the MSB.
                        delay_reg     <= {delay_reg[2:0], i_data_in};
                        config_counter <= config_counter + 1;
                    end else begin
                        config_counter <= 0;
                        state          <= COUNT;
                        // Initialize counters for the counting phase.
                        cycle_counter  <= 0;
                        block_counter  <= 0;
                    end
                end

                COUNT: begin
                    // Count cycles within the current 1000-cycle block.
                    if (cycle_counter == 10'd1000) begin
                        cycle_counter  <= 0;
                        block_counter  <= block_counter + 1;
                    end else begin
                        cycle_counter <= cycle_counter + 1;
                    end

                    // Update o_time_left at the beginning of each new 1000-cycle block.
                    // o_time_left = delay_reg - block_counter.
                    if (cycle_counter == 0)
                        o_time_left <= delay_reg - block_counter;

                    // Assert o_processing during the counting phase.
                    o_processing <= 1;

                    // Check if the counting phase is complete.
                    // The timer counts for (delay_reg + 1) * 1000 cycles.
                    if (block_counter == delay_reg + 1)
                        state <= DONE;
                end

                DONE: begin
                    // In DONE state, assert o_completed and de-assert o_processing.
                    o_completed  <= 1;
                    o_processing <= 0;
                    // Wait for the acknowledgment signal (i_ack) to reset the module.
                    if (i_ack) begin
                        state          <= IDLE;
                        // Clear outputs and internal registers.
                        o_completed    <= 0;
                        o_time_left    <= 4'b0000;
                        delay_reg      <= 4'b0000;
                        cycle_counter  <= 0;
                        block_counter  <= 0;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule