module nbit_swizzling #(parameter DATA_WIDTH = 64) (
  input wire [DATA_WIDTH-1:0] data_in,
  input wire [1:0] sel,
  output reg [DATA_WIDTH-1:0] data_out
);

  // Bitwise operations to reverse the data based on the selection signal
  always @(*) begin
    if (sel == 2'b00) begin
      // Reverse the entire input
      data_out = ~data_in;
    end else if (sel == 2'b01) begin
      // Reverse the first half of the input
      data_out = {data_in[DATA_WIDTH-2:0], data_in[DATA_WIDTH-1:1]};
    end else if (sel == 2'b10) begin
      // Reverse the second half of the input
      data_out = {data_in[DATA_WIDTH-4:2], data_in[DATA_WIDTH-1:4]};
    end else if (sel == 2'b11) begin
      // Reverse all sections of the input
      data_out = {data_in[DATA_WIDTH-8:4], data_in[DATA_WIDTH-7:5], data_in[DATA_WIDTH-6:6], data_in[DATA_WIDTH-5:7], data_in[DATA_WIDTH-4:8], data_in[DATA_WIDTH-3:10], data_in[DATA_WIDTH-2:12], data_in[DATA_WIDTH-1:14]};
    end else begin
      // Default case: do not modify the input
      data_out = data_in;
    end
  end

endmodule