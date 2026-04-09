// tx_block
module tx_block(
    input clk,               // Clock input
    input reset_n,           // Active-low reset
    input [63:0] data_in,    // 64-bit data input
    input [2:0] sel,         // Selection input
    output reg serial_out,   // Serial data output
    output done,             // Done signal
    output serial_clk        // Clock for serial data
);

// Internal registers
reg [63:0] data_reg;         // Register to hold the data being transmitted
reg [6:0] bit_count;         // Counter to track number of bits to transmit
reg [6:0] reg_count;         // Register for counting bits for serial clock control
reg [6:0] temp_reg_count;    // Temporary register to track reg_count

// Lookup table for selection
parameter [3:0] sel_widths = '{
    4'd0, 64'h0,  // 0 bits, no data
    4'd1, 64'h56'h0, // 8 bits, lowest
    4'd2, 64'h48'h0, // 16 bits, lowest
    4'd3, 64'h32'h0, // 32 bits, lowest
    4'd4, 64'h64'h0  // 64 bits, all data
};

// Combinational logic for selection
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg = sel_widths[sel];
        bit_count = sel_widths[sel];
        reg_count = sel_widths[sel];
        temp_reg_count <= 7'd0;
    end
    else begin
        temp_reg_count <= reg_count;
    end
end

// Sequential logic with clock enable
always @(posedge clk enable) begin
    if (enable && bit_count > 7'd0) begin
        data_reg <= data_reg >> 1;
        bit_count <= bit_count - 1'd1;
        reg_count <= reg_count + 1'd1;
    end
end

// Serial clock generation
always @(posedge clk enable) begin
    if (enable && temp_reg_count !== 7'd0) begin
        serial_clk = clk;
    end
end

// Combinational logic for serial output
always @(posedge clk enable or negedge reset_n) begin
    if (!reset_n) begin
        serial_out <= 1'b0;
    end
    else if (reg_count > 7'd0) begin
        serial_out <= data_reg[bit_count - 1];
    end
end

endmodule

// rx_block
module rx_block(
    input wire clk,              // Clock input
    input wire reset_n,          // Active-low reset
    input wire data_in,         // Serial input data
    input wire serial_clk,      // Clock signal for serial data
    input wire [2:0] sel,       // Selection output
    output reg done,           // Done signal
    output reg [63:0] data_out  // Parallel output data
);

// Internal registers
reg [63:0] data_reg;         // Register to hold incoming serial data
reg [7:0] bit_count;         // Counter for the number of bits received
reg [7:0] count;           // General purpose counter to sync with bit_count

// Sequential logic with clock enable
always @(posedge clk enable or negedge reset_n) begin
    if (!reset_n) begin
        count <= 8'd0;
        done <= 1'b0;
        data_reg <= 64'h0;
    end
    else if (count >= bit_count && count != 8'd0) begin
        done <= 1'b1;
        case(sel)
          3'b000: data_out <= 64'h0;
          3'b001: data_out <= {56'h0, data_reg};
          3'b010: data_out <= {48'h0, data_reg};
          3'b011: data_out <= {32'h0, data_reg};
          3'b100: data_out <= data_reg;
          default: data_out <= 64'h0;
        endcase
    end
    else if (bit_count > 8'd0) begin
        count <= count + 1'd1;
        done <= 1'b0;
    end
end

endmodule

module sync_serial_communication_tx_rx(
    input clk,                     // Clock signal
    input reset_n,                 // Active low reset signal
    input [2:0] sel,               // Selection signal for TX block
    input [63:0] data_in,          // 64-bit data input for TX block
    output [63:0] data_out,        // 64-bit data output from RX block
    output done                    // Done signal indicating completion
);

// Instantiate the TX block
tx_block uut_tx_block (
    .clk(clk),                     // Clock input to TX block
    .reset_n(reset_n),             // Reset input to TX block
    .data_in(data_in),             // 64-bit data input to TX block
    .sel(sel),                     // Selection signal to TX block
    .serial_out(serial_out),       // Serial data output from TX block
    .done(done),                // Done signal from TX block
    .serial_clk(serial_clk)        // Clock for serial data transmission
);

// Instantiate the RX block
rx_block uut_rx_block (
    .clk(clk),                     // Clock input to RX block
    .serial_clk(serial_clk),    // Serial clock output from TX block
    .reset_n(reset_n),             // Reset input to RX block
    .sel(sel),                     // Selection signal to RX block
    .data_in(tx_out),              // Serial data input to RX block
    .data_out(data_out),           // 64-bit data output from RX block
    .done(done)                    // Done signal from RX block
);

endmodule
