module sipo_top #(
  parameter DATA_WIDTH = 16,
  parameter SHIFT_DIRECTION = 1,  // 1 for left shift, 0 for right shift
  parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1)
)(
  input  clk,
  input  rst,
  input  serial_in,
  input  shift_en,
  input  [CODE_WIDTH-1:0] received,
  output done,
  output [DATA_WIDTH-1:0] data_out,
  output [CODE_WIDTH-1:0] encoded,
  output error_detected,
  output error_corrected
);

  // Internal signals from the SIPO and ECC blocks
  wire [DATA_WIDTH-1:0] parallel_out;
  wire done_sipo;
  wire [DATA_WIDTH-1:0] ecc_data_out;
  wire [CODE_WIDTH-1:0] ecc_encoded;
  wire ecc_error_detected;
  wire ecc_error_corrected;

  // Instantiate the Serial in Parallel Out module
  serial_in_parallel_out_8bit #(
    .WIDTH(DATA_WIDTH),
    .SHIFT_DIRECTION(SHIFT_DIRECTION)
  ) sipo_inst (
    .clk      (clk),
    .rst      (rst),
    .sin      (serial_in),
    .shift_en (shift_en),
    .done     (done_sipo),
    .parallel_out (parallel_out)
  );

  // Instantiate the one-bit ECC module
  onebit_ecc #(
    .CODE_WIDTH(CODE_WIDTH)
  ) ecc_inst (
    .data_in     (parallel_out),
    .received    (received),
    .data_out    (ecc_data_out),
    .encoded     (ecc_encoded),
    .error_detected (ecc_error_detected),
    .error_corrected (ecc_error_corrected)
  );

  // Drive the top-level outputs from the instantiated modules
  assign done          = done_sipo;
  assign data_out      = ecc_data_out;
  assign encoded       = ecc_encoded;
  assign error_detected= ecc_error_detected;
  assign error_corrected= ecc_error_corrected;

endmodule


// Modified Serial in Parallel Out module with configurable width and shift direction.
// It shifts in serial data when shift_en is high and asserts 'done' after a full word is shifted.
module serial_in_parallel_out_8bit #(
  parameter WIDTH = 64,
  parameter SHIFT_DIRECTION = 1  // 1: left shift; 0: right shift
)(
  input  clk,
  input  rst,
  input  sin,
  input  shift_en,
  output reg done,
  output reg [WIDTH-1:0] parallel_out
);

  integer counter;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      parallel_out <= 0;
      done         <= 0;
      counter      <= 0;
    end
    else begin
      if (shift_en) begin
        if (counter < WIDTH-1) begin
          if (SHIFT_DIRECTION == 1) begin
            // Left shift: new MSB is sin; shift right
            parallel_out <= { sin, parallel_out[WIDTH-1:1] };
          end
          else begin
            // Right shift: new LSB is sin; shift left
            parallel_out <= { parallel_out[WIDTH-2:0], sin };
          end
          counter <= counter + 1;
        end
        else begin
          // After the final shift, assert done
          done <= 1;
        end
      end
      else begin
        done <= 0;
      end
    end
  end

endmodule