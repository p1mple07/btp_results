module secure_read_write_register_bank #(
  parameter int p_address_width = 8,
  parameter int p_data_width = 8,
  parameter int p_unlock_code_0 = 8'hAB,
  parameter int p_unlock_code_1 = 8'hCD
) (
  input logic [p_address_width-1:0] i_addr,
  input logic [p_data_width-1:0] i_data_in,
  input logic i_read_write_enable,
  input logic i_capture_pulse,
  input logic i_rst_n,
  output logic [p_data_width-1:0] o_data_out
);

  logic unlock_sequence_complete;
  logic [p_address_width-1:0] addr_for_write;
  logic [p_data_width-1:0] data_for_write;

  always_ff @(posedge i_capture_pulse or posedge i_rst_n) begin
    if (!i_rst_n) begin
      unlock_sequence_complete <= 1'b0;
      addr_for_write <= 0;
      data_for_write <= 0;
    end else begin
      // Check if unlock sequence is complete
      if ((i_addr == 0 && i_data_in == p_unlock_code_0) ||
          (i_addr == 1 && i_data_in == p_unlock_code_1)) begin
        unlock_sequence_complete <= 1'b1;
      } else begin
        unlock_sequence_complete <= 1'b0;
      end

      // Store address and data for write operation
      if (i_read_write_enable == 0) begin
        addr_for_write <= i_addr;
        data_for_write <= i_data_in;
      end
    end
  end

  // Output data based on read or write operation
  assign o_data_out = (i_read_write_enable == 1)?
    ((addr_for_write == i_addr)? data_for_write : 0) : 0;

endmodule