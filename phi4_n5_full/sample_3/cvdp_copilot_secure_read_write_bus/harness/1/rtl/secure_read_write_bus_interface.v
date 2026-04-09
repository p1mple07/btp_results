module secure_read_write_bus_interface (
    input  wire [p_addr_width-1:0] i_addr,
    input  wire [p_data_width-1:0] i_data_in,
    input  wire [7:0]              i_key_in,
    input  wire                    i_read_write_enable,  // 1 = read, 0 = write
    input  wire                    i_capture_pulse,
    input  wire                    i_reset_bar,          // Asynchronous active-low reset
    output reg  [p_data_width-1:0] o_data_out,
    output reg                     o_error
);

  // Parameter definitions
  parameter p_configurable_key = 8'hAA;
  parameter p_data_width       = 8;
  parameter p_addr_width       = 8;

  // Internal memory array declaration
  // Memory depth is 2^p_addr_width words, each p_data_width bits wide.
  reg [p_data_width-1:0] mem [0:2**p_addr_width-1];

  // Loop index for memory clearing
  integer i;

  // Synchronous operations gated by i_capture_pulse with asynchronous reset
  always @(posedge i_capture_pulse or negedge i_reset_bar) begin
    if (!i_reset_bar) begin
      // Asynchronous reset: clear all internal registers and memory
      o_error         <= 1'b1;
      o_data_out      <= {p_data_width{1'b0}};
      for (i = 0; i < 2**p_addr_width; i = i + 1) begin
        mem[i] <= {p_data_width{1'b0}};
      end
    end
    else begin
      // Check if the provided key matches the internal configurable key
      if (i_key_in == p_configurable_key) begin
        if (!i_read_write_enable) begin
          // Write operation (authorized)
          mem[i_addr] <= i_data_in;
          o_data_out  <= {p_data_width{1'b0}}; // Default output for write is 0
          o_error     <= 1'b0;
        end
        else begin
          // Read operation (authorized)
          o_data_out <= mem[i_addr];
          o_error    <= 1'b0;
        end
      end
      else begin
        // Unauthorized access: flag error and default outputs to 0
        o_error    <= 1'b1;
        o_data_out <= {p_data_width{1'b0}};
      end
    end
  end

endmodule