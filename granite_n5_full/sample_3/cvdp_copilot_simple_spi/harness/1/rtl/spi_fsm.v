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

// Define FSM states
localparam IDLE = 2'b00;
localparam TRANSMIT = 2'b01;
localparam CLOCK_TOGGLE = 2'b10;
localparam ERROR = 2'b11;

// Register for FSM state
reg [1:0] fsm_state;

// Register for counting bits left to transmit
reg [4:0] bits_left;

// Register for storing the MSB of the data to be transmitted
reg [7:0] msb;

// Register for storing the LSB of the data to be transmitted
reg [7:0] lsb;

// Register for storing the received data
reg [7:0] received_data;

// Register for indicating if an error has occurred
reg error;

// Initial conditions
initial begin
    fsm_state <= IDLE;
    bits_left <= 16'd10;
    msb <= 8'd0;
    lsb <= 8'd0;
    received_data <= 8'd0;
    error <= 1'b0;
end

always @(posedge i_clk) begin
    case (fsm_state)
        IDLE: begin
            if (i_enable == 1'b1) begin
                o_spi_cs_b <= 1'b1;
                o_spi_clk <= 1'b0;
                o_spi_data <= 1'b0;
                o_bits_left <= 16'd10;
                fsm_state <= TRANSMIT;
            end else begin
                fsm_state <= IDLE;
            end
        end
        TRANSMIT: begin
            if (i_enable == 1'b1) begin
                o_spi_cs_b <= 1'b0;
                o_spi_clk <= 1'b1;
                o_spi_data <= i_data_in[7:0];
                bits_left <= bits_left - 1'b1;
                if (bits_left == 1'b0) begin
                    fsm_state <= CLOCK_TOGGLE;
                end
            end else begin
                fsm_state <= IDLE;
            end
        end
        CLOCK_TOGGLE: begin
            if (i_enable == 1'b1) begin
                o_spi_cs_b <= 1'b1;
                o_spi_clk <= 1'b0;
                o_spi_data <= 1'b0;
                if (received_data!= i_data_in) begin
                    error <= 1'b1;
                    fsm_state <= ERROR;
                end else begin
                    error <= 1'b0;
                    fsm_state <= IDLE;
                end
            end else begin
                fsm_state <= IDLE;
            end
        end
        ERROR: begin
            if (i_enable == 1'b1) begin
                o_spi_cs_b <= 1'b0;
                o_spi_clk <= 1'b0;
                o_spi_data <= 1'b0;
                fsm_state <= IDLE;
            end else begin
                fsm_state <= IDLE;
            end
        end
    endcase
end

endmodule