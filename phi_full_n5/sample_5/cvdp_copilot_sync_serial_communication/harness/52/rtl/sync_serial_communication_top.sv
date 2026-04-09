module sync_serial_communication_tx_rx(
    input clk,                     // Clock signal
    input reset_n,                 // Active low reset signal
    input [2:0] sel,               // Selection signal for TX block
    input [63:0] data_in,          // 64-bit data input for TX block
    output [63:0] data_out,        // 64-bit data output from RX block
    output done                    // Done signal indicating completion
);

// Internal signals
wire tx_out;                       // Serial data output from TX block
wire temp_reg_count;              // Temporary register to track reg_count

// Instantiate the TX block
tx_block uut_tx_block (
    .clk(clk),                     // Clock input to TX block
    .reset_n(reset_n),             // Reset input to TX block
    .data_in(data_in),             // 64-bit data input to TX block
    .sel(sel),                     // Selection signal to TX block
    .serial_out(tx_out),           // Serial data output from TX block
    .done(temp_reg_count),        // Temporary register for serial clock control
    .serial_clk(temp_reg_count)     // Temporary serial clock output
);

// Instantiate the RX block
rx_block uut_rx_block (
    .clk(clk),                     // Clock input to RX block
    .serial_clk(temp_reg_count),    // Temporary serial clock input to RX block
    .reset_n(reset_n),             // Reset input to RX block
    .sel(sel),                     // Selection signal to RX block
    .data_in(tx_out),              // Serial data input to RX block
    .data_out(data_out),           // 64-bit data output from RX block
    .done(done)                    // Done signal from RX block
);

endmodule

// tx_block
module tx_block(
    input clk,               // Clock input
    input reset_n,           // Active-low reset input
    input [63:0] data_in,    // 64-bit parallel data input
    input [2:0] sel,         // Selection input to choose data width
    output reg serial_out,   // Serial data output
    output reg done,         // Done signal indicating completion of transmission
    output reg serial_clk        // Clock for serial data transmission
);

// Internal registers
reg [63:0] data_reg;         // Register to hold the data being transmitted
reg [6:0] bit_count;         // Counter to track number of bits to transmit
reg [6:0] temp_reg_count;    // Temporary register to track reg_count

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg <= 64'h0;			     	           // Clear the data register
        bit_count <= 7'd0;			     	           // Reset bit count to zero
        temp_reg_count <= 7'h0;			     	           // Reset temp_reg_count to zero
    end else begin
        case (sel)
            3'b000: begin
                data_reg <= 64'h0;             	   // No data selected
                bit_count <= 7'd0;                     // No bits to transmit
            end
            3'b001: begin
                data_reg <= {56'h0, data_in[7:0]};    // Transmit lowest 8 bits
                bit_count <= 7'd7;              	   // 8 bits to transmit
            end
            3'b010: begin
                data_reg <= {48'h0, data_in[15:0]};   // Transmit lowest 16 bits
                bit_count <= 7'd15;             	   // 16 bits to transmit
            end
            3'b011: begin
                data_reg <= {32'h0, data_in[31:0]};   // Transmit lowest 32 bits
                bit_count <= 7'd31;             	   // 32 bits to transmit
            end
            3'b100: begin
                data_reg <= data_in[63:0];     	   // Transmit all 64 bits
                bit_count <= 7'd63;             	   // 64 bits to transmit
            end
            default: begin
                data_reg <= 64'h0;             	   // Default case: no data
                bit_count <= 7'h0;              	   // No bits to transmit
            end
        end
        bit_count <= bit_count + 3'b; // Introduce 3-cycle latency
    end
end

// Serial clock generation
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        temp_reg_count <= 7'h0;					           // Reset temporary reg_count
    end
    else begin
        temp_reg_count <= bit_count;			           // Update temp_reg_count with current bit_count
    end
end

// Serial output logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        serial_clk <= 1'b0;				                  // Reset serial clock
    end
    else if (temp_reg_count > 7'h0) begin
        serial_clk <= temp_reg_count;                     // Assign serial_clk from temp_reg_count
    end
end

// Done signal logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        done <= 1'b0;					                  // Reset done
    end
    else if (temp_reg_count == bit_count) begin
        done <= 1'b1; 			                          // Set done when bit_count reaches zero
    end
    else begin
        done <= 1'b0;					                  // Clear done during transmission
    end
end

endmodule

// rx_block
module rx_block(
    input wire clk,  			    // clock input
    input wire reset_n,			    // Active-low reset
    input wire data_in,			    // Serial input data
    input wire serial_clk,		    // Clock signal for serial data
    input wire [2:0] sel,           // Selection output to choose data width
    output reg done,			    // Done signal to indicate data reception complete
    output reg [63:0] data_out  	// Parallel output data after serial operation

);

// Internal registers
reg [63:0] data_reg;		    // Register to hold incoming serial data
reg [7:0] bit_count;		    // Counter for the number of bits received
reg [7:0] count;			    // General purpose counter to sync with bit_count

always @(posedge serial_clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg <= 64'h0;					         // Clear the data register
        bit_count <= 8'd0;					         // Clear the bit counter
        count <= 8'd0;					         // Clear the bit counter
        done <= 1'b0;					         // Deassert done
        data_out <= 64'h0;					     // Clear the output data register
    end else if (count >= bit_count && count != 8'd0) begin
        count <= count+ 1'b1;				     // Increment count
        done <= 1'b1;					             // Assert done when all bits are received
        case(sel)
            3'b000:begin
                data_out <= 64'h0;                   // no bits to transmit
            end
            3'b001:begin
                data_out <= {56'h0,data_reg};        // 8 bits of data_reg
            end
            3'b010:begin
                data_out <= {48'h0,data_reg};        // 16 bits of data_reg
            end
            3'b011:begin
                data_out <= {32'h0,data_reg};        // 32 bits of data_reg
            end
            3'b100:begin
                data_out <= data_reg;                // 64 bits of data_reg
            end
            default:begin
                data_out <= 64'h0;                   // no bits to transmit, default state
            end
        end
    end else if (bit_count > 8'd0) begin
        bit_count <= bit_count - 1'b1;                // Decrement the bit count
        count <= count+ 1'b1;				     // Increment count
        done <= 1'b0;					         // Clear done while receiving
    end else begin
        bit_count <= 8'd0;					         // Reset bit count
        count <= 8'd0;					         // Reset count
        done <= 1'b0;					         // Clear done
    end
end

endmodule
