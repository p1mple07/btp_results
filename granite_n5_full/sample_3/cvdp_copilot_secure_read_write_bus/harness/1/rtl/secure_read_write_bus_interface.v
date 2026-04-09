module secure_read_write_bus_interface (
  input logic [7:0] i_addr, // Target address for read or write operations
  input logic [7:0] i_data_in, // Data to be written during a write operation
  input logic [7:0] i_key_in, // Key provided by the initiator for operation authorization
  input logic i_read_write_enable, // Specifies the requested operation; 1 for read, 0 for write
  input logic i_capture_pulse, // Qualifies input capture for addr, data_in, key_in, and read_write_enable
  input logic i_reset_bar, // Asynchronous, active-low reset to initialize internal states and registers

  output logic [7:0] o_data_out, // Data output during a read operation, valid only if the input key matches the internal key
  output logic o_error // Asserted if the input key is incorrect and deserted if input key is correct
);

  // Internal parameters and signals
  parameter p_data_width = 8; // Configurable data width, default is 8 bits
  parameter p_addr_width = 8; // Configurable address width, default is 8 bits
  parameter p_configurable_key = 8'hAA; // Internal 8-bit key, default value is 8'hAA
  logic [7:0] internal_key; // Internal 8-bit key
  logic [7:0] internal_data; // Internal storage for data

  always_ff @(posedge i_capture_pulse) begin
    if (i_reset_bar == 1'b0) begin
      // Reset internal registers and outputs
      internal_key <= p_configurable_key;
      internal_data <= 8'b0;
      o_data_out <= 8'b0;
      o_error <= 1'b0;
    end else begin
      // Read operation
      if (i_read_write_enable == 1'b1) begin
        if (internal_key == i_key_in) begin
          o_data_out <= internal_data;
          o_error <= 1'b0;
        end else begin
          o_error <= 1'b1;
          o_data_out <= 8'b0;
        end
      end
      // Write operation
      if (i_read_write_enable == 1'b0) begin
        if (internal_key == i_key_in) begin
          internal_data <= i_data_in;
          o_error <= 1'b0;
        end else begin
          o_error <= 1'b1;
        end
      end
    end
  end

endmodule