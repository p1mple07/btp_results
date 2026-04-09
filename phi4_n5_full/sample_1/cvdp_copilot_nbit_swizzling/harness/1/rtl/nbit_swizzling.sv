module nbit_swizzling #(parameter DATA_WIDTH = 64) (
  input  logic [DATA_WIDTH-1:0] data_in,
  input  logic [1:0]             sel,
  output logic [DATA_WIDTH-1:0] data_out
);

  // Function to reverse the bits of an input vector of a given width.
  // The function is parameterized so that it can be used on vectors of various widths.
  function automatic logic [WIDTH-1:0] reverse_bits #(parameter WIDTH = DATA_WIDTH) (
    input logic [WIDTH-1:0] in
  );
    logic [WIDTH-1:0] out;
    integer i;
    begin
      out = '0;
      for (i = 0; i < WIDTH; i = i + 1) begin
        out[i] = in[WIDTH-1-i];
      end
      reverse_bits = out;
    end
  endfunction

  // Combinational logic to perform selective bit reversal based on the sel input.
  always_comb begin
    case (sel)
      2'd0: // sel = 0: Reverse the entire input.
        data_out = reverse_bits#(DATA_WIDTH)(data_in);

      2'd1: // sel = 1: Divide data_in into two equal halves and reverse each half.
        data_out = { reverse_bits#(DATA_WIDTH/2)(data_in[DATA_WIDTH/2-1:0]), 
                     reverse_bits#(DATA_WIDTH/2)(data_in[DATA_WIDTH-1:DATA_WIDTH/2]) };

      2'd2: // sel = 2: Divide data_in into four equal parts and reverse each part.
        data_out = { reverse_bits#(DATA_WIDTH/4)(data_in[DATA_WIDTH/4-1:0]), 
                     reverse_bits#(DATA_WIDTH/4)(data_in[DATA_WIDTH/2-1:DATA_WIDTH/4]), 
                     reverse_bits#(DATA_WIDTH/4)(data_in[3*DATA_WIDTH/4-1:DATA_WIDTH/2]), 
                     reverse_bits#(DATA_WIDTH/4)(data_in[DATA_WIDTH-1:3*DATA_WIDTH/4]) };

      2'd3: // sel = 3: Divide data_in into eight equal parts and reverse each part.
        data_out = { reverse_bits#(DATA_WIDTH/8)(data_in[DATA_WIDTH/8-1:0]), 
                     reverse_bits#(DATA_WIDTH/8)(data_in[DATA_WIDTH/4-1:DATA_WIDTH/8]), 
                     reverse_bits#(DATA_WIDTH/8)(data_in[3*DATA_WIDTH/8-1:DATA_WIDTH/4]), 
                     reverse_bits#(DATA_WIDTH/8)(data_in[DATA_WIDTH/2-1:3*DATA_WIDTH/8]), 
                     reverse_bits#(DATA_WIDTH/8)(data_in[5*DATA_WIDTH/8-1:DATA_WIDTH/2]), 
                     reverse_bits#(DATA_WIDTH/8)(data_in[3*DATA_WIDTH/4-1:5*DATA_WIDTH/8]), 
                     reverse_bits#(DATA_WIDTH/8)(data_in[7*DATA_WIDTH/8-1:3*DATA_WIDTH/4]), 
                     reverse_bits#(DATA_WIDTH/8)(data_in[DATA_WIDTH-1:7*DATA_WIDTH/8]) };

      default: // Default case: Output matches the input.
        data_out = data_in;
    endcase
  end

endmodule