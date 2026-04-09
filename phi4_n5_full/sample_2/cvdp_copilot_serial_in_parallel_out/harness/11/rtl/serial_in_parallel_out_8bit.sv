module sipo_top which instantiates
// the serial_in_parallel_out_8bit and onebit_ecc modules.

module sipo_top #(
    parameter DATA_WIDTH = 16,
    parameter SHIFT_DIRECTION = 1,
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH+1)
)
(
    input clk,
    input rst,
    input serial_in,
    input shift_en,
    input [CODE_WIDTH-1:0] received,
    output done,
    output [DATA_WIDTH-1:0] data_out,
    output [CODE_WIDTH-1:0] encoded,
    output error_detected,
    output error_corrected
);

   // Wires to connect the SIPO module to the ECC block
   wire [DATA_WIDTH-1:0] sipo_parallel_out;
   wire sipo_done;

   // Instantiate the Serial in Parallel Out module
   serial_in_parallel_out_8bit #(
      .WIDTH(64),                // Number of shifts to complete (default 64)
      .SHIFT_DIRECTION(SHIFT_DIRECTION),
      .DATA_WIDTH(DATA_WIDTH)     // Overriding default DATA_WIDTH for output width
   ) sipo_inst (
      .clk(clk),
      .rst(rst),
      .sin(serial_in),
      .shift_en(shift_en),
      .done(sipo_done),
      .parallel_out(sipo_parallel_out)
   );

   // Instantiate the One Bit ECC module
   onebit_ecc #(
      .DATA_WIDTH(DATA_WIDTH),
      .CODE_WIDTH(CODE_WIDTH)
   ) ecc_inst (
      .data_in(sipo_parallel_out),
      .received(received),
      .data_out(data_out),
      .encoded(encoded),
      .error_detected(error_detected),
      .error_corrected(error_corrected)
   );

   // Drive the top-level done signal from the SIPO module's done output
   assign done = sipo_done;

endmodule