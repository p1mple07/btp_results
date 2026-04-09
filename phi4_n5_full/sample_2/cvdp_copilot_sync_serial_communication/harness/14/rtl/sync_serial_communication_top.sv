
module tx_block(
    input clk,               // Clock input
    input reset_n,           // Active-low reset input
    input [63:0] data_in,    // 64-bit parallel data input
    input [2:0] sel,         // Selection input to choose data width
    output reg serial_out,   // Serial data output
    output reg done,         // Done signal indicating completion of transmission
    output serial_clk        // Clock for serial data transmission
);

// Internal registers
reg [63:0] data_reg;         // Register to hold the data being transmitted
reg [6:0] bit_count;         // Counter to track number of bits to transmit
reg [6:0] reg_count;         // Register for counting bits for serial clock control
reg [6:0] temp_reg_count;    // Temporary register to track reg_count

// Sequential block for state control and data selection
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        // Reset all values on active-low reset
        data_reg     <= 64'h0;			     	           // Clear the data register
        bit_count    <= 7'h0;			     	           // Reset bit count to zero
        reg_count    <= 7'h0;		             	       // Reset reg_count to zero
    end else begin
        if (done == 1'b1) begin
	    // Case block to determine the width of data to transmit based on the 'sel' input
            case (sel)
                3'b000: begin
                    data_reg  <= 64'h0;             	   // No data selected
                    bit_count <= 7'd0;                     // No bits to transmit
                end
                3'b001: begin
                    data_reg  <= {56'h0, data_in[7:0]};    // Transmit lowest 8 bits
                    bit_count <= 7'd7;              	   // 8 bits to transmit
                end
                3'b010: begin
                    data_reg  <= {48'h0, data_in[15:0]};   // Transmit lowest 16 bits
                    bit_count <= 7'd15;             	   // 16 bits to transmit
                end
                3'b011: begin
                    data_reg  <= {32'h0, data_in[31:0]};   // Transmit lowest 32 bits
                    bit_count <= 7'd31;             	   // 32 bits to transmit
                end
                3'b100: begin
                    data_reg  <= data_in[63:0];     	   // Transmit all 64 bits
                    bit_count <= 7'd63;             	   // 64 bits to transmit
                end
                default: begin
                    data_reg  <= 64'h0;             	   // Default case: no data
                    bit_count <= 7'h0;              	   // No bits to transmit
                end
            endcase
           
        end else if (bit_count > 7'h0) begin
            data_reg   <= data_reg >> 1;                   // Shift the data to the right
            bit_count  <= bit_count - 1'b1;                // Decrement the bit count
            
        end
        reg_count <= bit_count;                            // Update reg_count for serial clock control
    end
end
