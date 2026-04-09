module sipo_top#(
    parameter DATA_WIDTH = 16,
    parameter SHIFT_DIRECTION = 1,
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1)
) (
    input clk,
    input reset_n,
    input serial_in,
    input shift_en,
    input [CODE_WIDTH-1:0] received,
    output done,
    output [DATA_WIDTH-1:0] data_out,
    output [CODE_WIDTH-1:0] encoded,
    output error_detected,
    output error_corrected,
    output reg [CRC_WIDTH-1:0] crc_out,
    output reg crc_error
);

  // Existing IP blocks ...

  // CRC generator instantiation
  crc_generator #(
      DATA_WIDTH,
      CRC_WIDTH = DATA_WIDTH / 2,
      POLY = 8'b10101010
  ) uut_crc (
      .data_in(received),
      .crc_out(crc_out),
      .crc_error(crc_error)
  );

endmodule
