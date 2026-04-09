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

    // Internal signals
    reg [1:0] internal_fsm_state = 2'b00; // Idle
    reg o_spi_clk_active = 1'b0; // SPI clock toggle

    // Reset and enable logic
    always @(posedge i_clk or posedge i_rst_b) begin
        if (i_rst_b) begin
            internal_fsm_state <= 2'b00;
            o_spi_cs_b <= 1'b1;
            o_spi_clk <= 1'b0;
            o_spi_data <= 16'b0;
            o_bits_left <= 5'd16;
            o_done <= 1'b0;
            o_fsm_state <= 2'b00;
        end else if (i_enable) begin
            internal_fsm_state <= 2'b00;
            o_spi_cs_b <= 1'b0;
        end
    end

    // Enable and fault handling
    always @(posedge i_clk) begin
        if (i_clear) begin
            internal_fsm_state <= 2'b00;
            o_spi_cs_b <= 1'b1;
            o_spi_clk <= 1'b0;
            o_spi_data <= 16'b0;
            o_bits_left <= 5'd16;
            o_done <= 1'b0;
            o_fsm_state <= 2'b00;
        end else if (i_fault) begin
            internal_fsm_state <= 2'b11;
            o_spi_cs_b <= 1'b1;
            o_spi_clk <= 1'b0;
            o_spi_data <= 16'b0;
            o_bits_left <= 5'd10;
            o_done <= 1'b0;
            o_fsm_state <= 2'b11;
        end
    end

    // FSM states
    always @(posedge i_clk) begin
        case (internal_fsm_state)
            2'b00: begin
                if (i_enable) begin
                    internal_fsm_state <= 2'b01;
                    o_spi_cs_b <= 1'b0;
                    o_spi_clk <= 1'b0;
                    o_spi_data <= i_data_in[15];
                    o_bits_left <= 5'd15;
                    o_done <= 1'b0;
                end
            end
            2'b01: begin
                if (!o_clear && !i_clear) begin
                    if (o_bits_left == 1) begin
                        internal_fsm_state <= 2'b10;
                        o_spi_clk_active <= 1'b1;
                        o_spi_data <= i_data_in[14];
                        o_bits_left <= 5'd14;
                    end
                    o_spi_cs_b <= 1'b0;
                    o_spi_clk <= o_spi_clk_active;
                    o_done <= 1'b0;
                end
            end
            2'b10: begin
                if (!o_clear && !i_clear) begin
                    internal_fsm_state <= 2'b00;
                    o_spi_clk_active <= 1'b0;
                    o_spi_cs_b <= 1'b1;
                    o_spi_data <= 16'b0;
                    o_bits_left <= 5'd16;
                    o_done <= 1'b0;
                end
            end
            2'b11: begin
                o_spi_cs_b <= 1'b1;
                o_spi_clk <= 1'b0;
                o_spi_data <= 16'b0;
                o_bits_left <= 5'd10;
                o_done <= 1'b0;
            end
        endcase
    end

    // Output logic
    assign o_fsm_state = internal_fsm_state;

endmodule
