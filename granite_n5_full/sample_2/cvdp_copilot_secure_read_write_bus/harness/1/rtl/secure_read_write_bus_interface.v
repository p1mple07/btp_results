module secure_read_write_bus_interface(
  input logic [7:0] i_addr,
  input logic [7:0] i_data_in,
  input logic [7:0] i_key_in,
  input logic i_read_write_enable,
  input logic i_capture_pulse,
  input logic i_reset_bar,
  output logic [7:0] o_data_out,
  output logic o_error
);

  // Internals
  logic [7:0] internal_key = 8'hAA;
  logic [7:0] data_register[0:255];

  // Read operation
  always @(posedge i_capture_pulse) begin
    if (i_read_write_enable == 1'b1 && i_key_in == internal_key) begin
      o_error <= 1'b0;
      o_data_out <= data_register[i_addr];
    end else begin
      o_error <= 1'b1;
      o_data_out <= 8'b0;
    end
  end

  // Write operation
  always @(posedge i_capture_pulse) begin
    if (i_read_write_enable == 1'b0 && i_key_in == internal_key) begin
      data_register[i_addr] <= i_data_in;
    end
  end

  // Reset handling
  always @(posedge i_reset_bar) begin
    internal_key <= 8'hAA;
    data_register <= {8{1'b0}};
    o_error <= 1'b0;
  end

endmodule