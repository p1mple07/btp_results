module sipo_top (
  input clock,
  input rst,
  output reg [16:0] parallel_out,
  output reg [16:0] data_out,
  output reg [21:0] encoded,
  output reg error_detected,
  output reg error_corrected
)
  parameter DATA_WIDTH = 16;
  parameter SHIFT_DIRECTION = 1;
  parameter CODE_WIDTH = DATA_WIDTH + log2(DATA_WIDTH + 1);

  always @(posedge clock)
    begin
      // Shift logic
      if (shift_en) {
        if (SHIFT_DIRECTION == 1) {
          parallel_out[16] <= parallel_out[15];
          parallel_out[15] <= parallel_out[14];
          // ... continue shifting left ...
          parallel_out[1] <= parallel_out[0];
          parallel_out[0] <= serial_in;
        } else {
          parallel_out[0] <= parallel_out[1];
          parallel_out[1] <= parallel_out[2];
          // ... continue shifting right ...
          parallel_out[15] <= parallel_out[16];
          parallel_out[16] <= serial_in;
        }
      }
      
      // ECC logic
      onebit_ecc ec(
        data_in = parallel_out,
        received = encoded[CODE_WIDTH-1:0],
        data_out = data_out,
        encoded_out = encoded,
        error_detected = error_detected,
        error_corrected = error_corrected
      );
    end

    // Generate done signal
    done <= 1;
  end
  always @* begin
    done <= 0;
  end
endmodule

module serial_in_parallel_out_8bit (
  input clock,
  input serial_in,
  output reg [16:0] parallel_out,
  input shift_en,
  output reg [16:0] done
)
  // ... existing code with width changed to DATA_WIDTH ...
endmodule

module onebit_ecc (
  input [16:0] data_in,
  input [21:0] received,
  output [16:0] data_out,
  output [21:0] encoded,
  output error_detected,
  output error_corrected
)
  // Hamming code generation and error correction logic ...
endmodule