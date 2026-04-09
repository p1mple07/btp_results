module secure_read_write_bus_interface #(
  parameter [7:0] p_ configurable_key = 8'dAA, // Internal 8-bit key
  parameter int    p_data_width = 8,        // Configurable data width
  parameter int    p_addr_width = 8         // Configurable address width
) (
  input  wire [p_addr_width-1:0] i_addr,     // Target address for read or write operations
  input  wire [p_data_width-1:0] i_data_in,  // Data to be written during a write operation
  input  wire [7:0]               i_key_in,    // Key provided by the initiator for operation authorization
  input  wire                       i_read_write_enable, // Specifies the requested operation; 1 for read, 0 for write
  input  wire                       i_capture_pulse,    // Qualifies input capture for addr, data_in, key_in, and read_write_enable
  input  wire                       i_reset_bar,      // Asynchronous, active-low reset to initialize internal states and registers

  output reg  [p_data_width-1:0] o_data_out, // Data output during a read operation, valid only if the input key matches the internal key
  output reg                        o_error       // Asserted if the input key is incorrect and dessert if input key is correct
);

  reg [7:0] internal_key;
  reg [p_addr_width-1:0] addr;
  reg [p_data_width-1:0] data_in;
  reg read_write_enable;
  reg capture_pulse;
  reg reset_bar;
  reg [p_data_width-1:0] data_out;
  reg error;

  assign internal_key = p_configurable_key; // Set internal key to configured value
  assign addr = i_addr; // Assign input address to local register
  assign data_in = i_data_in; // Assign input data to local register
  assign read_write_enable = i_read_write_enable; // Assign input read/write enable to local register
  assign capture_pulse = i_capture_pulse; // Assign input capture pulse to local register
  assign reset_bar = i_reset_bar; // Assign input reset bar to local register

  always @(posedge capture_pulse) begin
    if (internal_key == i_key_in &&!error) begin
      if (read_write_enable) begin
        data_out <= addr == internal_key? data_in : 8'b0; // Output data if address matches internal key
      end else begin
        data_out <= addr == internal_key? data_in : 8'b0; // Output data if address matches internal key
        error <= internal_key!= i_key_in; // Set error flag if input key does not match internal key
      end
    end else begin
      data_out <= 8'b0; // Reset output data if input key is incorrect or internal key is changed
      error <= 1'b0; // Clear error flag if input key is incorrect or internal key is changed
    end
  end
endmodule