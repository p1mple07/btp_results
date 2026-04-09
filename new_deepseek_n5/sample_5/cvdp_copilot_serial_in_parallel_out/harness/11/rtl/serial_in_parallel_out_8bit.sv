module sipo_top (input clock, rst, serial_in, shift_en, received,
                  output reg [63:0] parallel_out, output reg [63:0] data_out,
                  output reg [70:0] encoded, output reg error_detected,
                  output reg error_corrected);

  parameter DATA_WIDTH = 64;
  parameter CODE_WIDTH = DATA_WIDTH + log2CDATA_WIDTH + 1);

  // SIPO block
  module serial_in_parallel_out_64bit (input clock, serial_in, shift_en,
                                       output reg [63:0] parallel_out);
    // Implementation of SIPO
  endmodule

  // ECC block
  module onebit_ecc (input [63:0] data_in, input [70:0] received,
                     output [63:0] data_out, output [70:0] encoded,
                     output error_detected, output error_corrected);
    // Implementation of onebit_ecc
  endmodule

  // Connect signals
  wire parallel_out [63:0] = serial_in_parallel_out_64bit.parallel_out;
  wire data_out [63:0] = onebit_ecc.data_out;
  wire encoded [70:0] = onebit_ecc.encoded;
  wire error_detected = onebit_ecc.error_detected;
  wire error_corrected = onebit_ecc.error_corrected;

  // Initialize
  serial_in_parallel_out_64bit.rst = rst;
  onebit_ecc.rst = rst;

  // Behavior
  always @(posedge clock) begin
    // Shift operation
    if (rst) begin
      parallel_out = 0;
      data_out = 0;
      encoded = 0;
      error_detected = 0;
      error_corrected = 0;
    end else begin
      if (shift_en) begin
        parallel_out [63:1] <= parallel_out [62:0];
        parallel_out [0] <= serial_in;
      end else begin
        parallel_out <= received;
      end
      if (rst) begin
        data_out = 0;
        encoded = 0;
        error_detected = 0;
        error_corrected = 0;
      end else begin
        if (shift_en) begin
          data_out [63:1] <= data_out [62:0];
          data_out [0] <= parallel_out [0];
        end else begin
          data_out <= encoded;
        end
        if (error_corrected) begin
          encoded = data_out;
        end
      end
    end
  end

  // Generate done signal for SIPO
  done = 0;
  if (rst) done = 1;
  else if (shift_en) begin
    if ( DATA_WIDTH == 64 ) begin
      done = 1;
    end else done = 0;
    end else done = 0;

  // Generate done signal for onebit_ecc
  onebit_ecc.done = 0;
  if (rst) onebit_ecc.done = 1;
  else if (error_corrected) begin
    onebit_ecc.done = 1;
    end else onebit_ecc.done = 0;
  endmodule