module secure_read_write_bus_interface #
(
  parameter p_configurable_key = 8'hAA,
  parameter p_data_width       = 8,
  parameter p_addr_width       = 8
)
(
  input  wire [p_addr_width-1:0]  i_addr,
  input  wire [p_data_width-1:0]  i_data_in,
  input  wire [7:0]               i_key_in,
  input  wire                     i_read_write_enable, // 1 = read, 0 = write
  input  wire                     i_capture_pulse,
  input  wire                     i_reset_bar,         // asynchronous active-low reset
  output reg  [p_data_width-1:0]  o_data_out,
  output reg                     o_error
);

  // Internal memory: depth = 2^p_addr_width, width = p_data_width.
  reg [p_data_width-1:0] mem [(1<<p_addr_width)-1:0];

  integer i;

  // Operations are gated by the rising edge of i_capture_pulse.
  // Asynchronous reset is active when i_reset_bar is low.
  always @(posedge i_capture_pulse or negedge i_reset_bar) begin
    if (!i_reset_bar) begin
      // Asynchronous reset: clear outputs and memory.
      o_error         <= 1'b0;
      o_data_out      <= {p_data_width{1'b0}};
      for (i = 0; i < (1<<p_addr_width); i = i + 1) begin
        mem[i] <= {p_data_width{1'b0}};
      end
    end
    else begin
      if (i_key_in == p_configurable_key) begin
        // Authorized access.
        o_error <= 1'b0;
        if (!i_read_write_enable) begin
          // Write operation: store i_data_in into memory at address i_addr.
          mem[i_addr] <= i_data_in;
          // For write operations, o_data_out remains 0.
          o_data_out <= {p_data_width{1'b0}};
        end
        else begin
          // Read operation: output data from memory at address i_addr.
          o_data_out <= mem[i_addr];
        end
      end
      else begin
        // Unauthorized access: flag error and set outputs to default (0).
        o_error    <= 1'b1;
        o_data_out <= {p_data_width{1'b0}};
      end
    end
  end

endmodule