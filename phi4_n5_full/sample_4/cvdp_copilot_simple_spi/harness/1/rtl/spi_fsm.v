// File: rtl/spi_fsm.v
module spi_fsm (
    input  wire         i_clk,       // System clock
    input  wire         i_rst_b,     // Active-low async reset
    input  wire [15:0]  i_data_in,   // 16-bit parallel data to transmit
    input  wire         i_enable,    // Enable block
    input  wire         i_fault,     // Fault indicator
    input  wire         i_clear,     // Forces FSM to clear/idle

    output reg          o_spi_cs_b,  // SPI chip select (active-low)
    output reg          o_spi_clk,   // SPI clock signal
    output reg          o_spi_data,  // Serialized SPI data output
    output reg [4:0]    o_bits_left, // Bits remaining to be transmitted
    output reg          o_done,      // Single-cycle pulse when done or error
    output reg [1:0]    o_fsm_state  // Current FSM state (00=Idle, 01=Transmit, 10=Clock, 11=Error)
);

    // State encoding
    localparam IDLE  = 2'b00;
    localparam TRANS = 2'b01;
    localparam CLOCK = 2'b10;
    localparam ERROR = 2'b11;

    // Internal registers
    reg [1:0] state;         // Current state
    reg [15:0] shift_reg;    // Shift register for data shifting
    reg [4:0]  bits_left;    // Bits remaining to transmit
    reg        spi_clk_reg;  // Internal register for SPI clock toggling
    reg [1:0]  prev_state;   // Previous state (for done pulse detection)
    reg        done_reg;     // Done signal register

    // FSM state and output logic
    always @(posedge i_clk or negedge i_rst_b) begin
        if (!i_rst_b) begin
            state         <= IDLE;
            shift_reg     <= 16'd0;
            bits_left     <= 5'd16;  // 16 bits to send (0x10)
            spi_clk_reg   <= 1'b0;
            prev_state    <= IDLE;
            // Set outputs to safe defaults on reset
            o_spi_cs_b    <= 1'b1;  // Chip select inactive (high)
            o_spi_clk     <= 1'b0;
            o_spi_data    <= 1'b0;
            o_bits_left   <= 5'd16;
            o_done        <= 1'b0;
            o_fsm_state   <= IDLE;
        end else begin
            // Save current state for transition detection
            prev_state <= state;
            
            // Check immediate control signals: clear and fault
            if (i_clear) begin
                // Force FSM to idle and reset all counters/outputs
                state         <= IDLE;
                shift_reg     <= 16'd0;
                bits_left     <= 5'd16;
                spi_clk_reg   <= 1'b0;
            end else if (i_fault && (prev_state != ERROR)) begin
                // Transition to ERROR state on fault (pulse done on transition)
                state         <= ERROR;
                shift_reg     <= 16'd0;
                bits_left     <= 5'd10;  // Safe default for bits_left in error
                spi_clk_reg   <= 1'b0;
            end else if (i_fault) begin
                // Remain in ERROR state if already in error
                state <= ERROR;
            end else begin
                // Normal FSM operation
                case (state)
                    IDLE: begin
                        // Wait for enable signal; if asserted, load data and begin transmission
                        if (i_enable) begin
                            shift_reg <= i_data_in;
                            bits_left <= 5'd16;
                            state     <= TRANS;
                        end else begin
                            state <= IDLE;
                        end
                    end
                    TRANS: begin
                        // In Transmit state, load the MSB of data into o_spi_data.
                        // Transition immediately to CLOCK state.
                        state <= CLOCK;
                    end
                    CLOCK: begin
                        // Toggle the SPI clock signal each cycle
                        spi_clk