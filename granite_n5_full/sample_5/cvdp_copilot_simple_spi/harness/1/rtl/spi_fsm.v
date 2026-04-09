module spi_fsm (
    input  wire         i_clk,       // System clock
    input  wire         i_rst_b,     // Active-low async reset
    input  wire [15:0]  i_data_in,   // Parallel 16-bit data to transmit
    input  wire         i_enable,    // Enable block
    input  wire         i_fault,     // Fault indicator
    input  wire         i_clear,     // Forces FSM to clear/idle
    
    output reg          o_spi_cs_b,  // SPI chip select (active-low)
    output reg          o_spi_clk,   // SPI clock
    output reg          o_spi_data,  // Serialized SPI data out
    output reg [4:0]    o_bits_left, // Bits left to transmit
    output reg          o_done,      // Single-cycle pulse when done or error
    output reg [1:0]    o_fsm_state  // FSM state for external monitoring
);

    // FSM state enum
    typedef enum {
        IDLE,
        TRANSMIT,
        CLOCK_TOGGLE,
        ERROR
    } fsm_state_t;

    // Register declarations
    reg [15:0]  r_data_out;
    reg [4:0]   r_bits_left;
    reg           r_en;
    reg           r_cl;
    reg           r_error;
    reg           r_done;
    reg [1:0]   r_state;

    // State transitions
    always @(posedge i_clk or posedge i_rst_b) begin
        if (i_rst_b == 1'b1) begin
            // Reset
            r_data_out <= 16'h0;
            r_bits_left <= 5'h10;
            r_en <= 1'b0;
            r_cl <= 1'b0;
            r_error <= 1'b0;
            r_done <= 1'b0;
            r_state <= IDLE;
        end else if (i_enable == 1'b1) begin
            case(r_state)
                IDLE: begin
                    // Start transmission
                    r_data_out <= i_data_in;
                    r_bits_left <= 5'h10;
                    r_state <= TRANSMIT;
                end
                TRANSMIT: begin
                    // Shift data out
                    r_spi_cs_b <= 1'b0;
                    r_spi_clk <= 1'b1;
                    r_spi_data <= r_data_out[15:8];
                    r_bits_left <= r_bits_left - 1;
                    if (r_bits_left == 5'h0) begin
                        // Last bit
                        r_state <= CLOCK_TOGGLE;
                    end else begin
                        // More bits
                        r_state <= TRANSMIT;
                    end
                end
                CLOCK_TOGGLE: begin
                    // Toggle clock
                    r_spi_clk <= ~r_spi_clk;
                    if (r_bits_left == 5'h0) begin
                        // Last bit
                        r_state <= IDLE;
                    end else begin
                        // More bits
                        r_state <= CLOCK_TOGGLE;
                    end
                end
                ERROR: begin
                    // Handle errors
                    r_error <= 1'b1;
                    r_done <= 1'b1;
                    r_state <= IDLE;
                end
            endcase
        end
    end

    // Assign outputs based on FSM state
    assign o_spi_cs_b = ~r_en & ~r_cl;
    assign o_spi_clk = r_spi_clk;
    assign o_spi_data = r_data_out[7:0];
    assign o_bits_left = r_bits_left;
    assign o_done = r_done & ~r_error;
    assign o_fsm_state = r_state;

endmodule