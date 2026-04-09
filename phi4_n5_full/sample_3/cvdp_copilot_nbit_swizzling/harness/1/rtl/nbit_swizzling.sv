module nbit_swizzling #(
  parameter DATA_WIDTH = 64
)(
  input  logic [DATA_WIDTH-1:0] data_in,
  input  logic [1:0]            sel,
  output logic [DATA_WIDTH-1:0] data_out
);

  // Check that DATA_WIDTH meets the constraints
  initial begin
    if ((DATA_WIDTH < 16) || (DATA_WIDTH % 8 != 0))
      $error("DATA_WIDTH must be >= 16 and a multiple of 8");
  end

  // Function: reverse_bits
  // Reverses the bits of a vector of width N.
  // N must be a compile-time constant.
  function automatic logic [N-1:0] reverse_bits(input logic [N-1:0] data, input int N);
    logic [N-1:0] out;
    integer i;
    begin
      out = '0;
      for (i = 0; i < N; i = i + 1) begin
        out[i] = data[N-1-i];
      end
      reverse_bits = out;
    end
  endfunction

  // Combinational logic for selective bit reversal
  always_comb begin
    if (sel == 0) begin
      // Case 0: Reverse the entire input
      data_out = reverse_bits(data_in, DATA_WIDTH);
    end
    else if (sel == 1) begin
      // Case 1: Divide into 2 halves and reverse each half separately
      data_out[DATA_WIDTH-1:DATA_WIDTH/2] = reverse_bits(data_in[DATA_WIDTH/2-1:0], DATA_WIDTH/2);
      data_out[DATA_WIDTH/2-1:0]           = reverse_bits(data_in[DATA_WIDTH-1:DATA_WIDTH/2], DATA_WIDTH/2);
    end
    else if (sel == 2) begin
      // Case 2: Divide into 4 segments and reverse each segment individually
      int seg_width = DATA_WIDTH >> 2; // DATA_WIDTH/4
      int i;
      for (i = 0; i < 4; i = i + 1) begin
        data_out[(i+1)*seg_width - 1 : i*seg_width] =
          reverse_bits(data_in[(i+1)*seg_width - 1 : i*seg_width], seg_width);
      end
    end
    else if (sel == 3) begin
      // Case 3: Divide into 8 segments and reverse each segment individually
      int seg_width = DATA_WIDTH >> 3; // DATA_WIDTH/8
      int i;
      for (i = 0; i < 8; i = i + 1) begin
        data_out[(i+1)*seg_width - 1 : i*seg_width] =
          reverse_bits(data_in[(i+1)*seg_width - 1 : i*seg_width], seg_width);
      end
    end
    else begin
      // Default: Output matches the input
      data_out = data_in;
    end
  end

endmodule