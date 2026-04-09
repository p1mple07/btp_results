module sync_serial_communication_top
#(
  parameter DATA_WIDTH = 64
)(
  input logic clk,
  input logic reset_n,
  input logic [DATA_WIDTH-1:0] data_in,
  input logic [2:0] sel,
  output logic [63:0] data_out,
  output logic done
);

  // Implement the transmitter and receiver modules here

endmodule

module tx_block
#(
  parameter DATA_WIDTH = 64
)(
  input logic clk,
  input logic reset_n,
  input logic [DATA_WIDTH-1:0] data_in,
  input logic [2:0] sel,
  output logic [63:0] data_out,
  output logic done
);

  // Implement the transmitter module here

endmodule

module rx_block
#(
  parameter DATA_WIDTH = 64
)(
  input logic clk,
  input logic reset_n,
  input logic [DATA_WIDTH-1:0] data_in,
  input logic [2:0] sel,
  output logic [63:0] data_out,
  output logic done
);

  // Implement the receiver module here

endmodule