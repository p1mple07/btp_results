module cascaded_adder #(
  parameter IN_DATA_WIDTH = 16,
  parameter IN_DATA_NS    = 4
) (
  input  wire                    clk,
  input  wire                    rst_n,

  input  wire                    i_valid,
  input  wire [(IN_DATA_WIDTH*IN_DATA_NS)-1:0] i_data,

  output reg                     o_valid,
  output reg [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] o_data
);

  reg [(IN_DATA_WIDTH*$clog2(IN_DATA_NS))-1:0] acc;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= 0;
      o_valid <= 1'b0;
    end else if (i_valid) begin
      acc <= {acc, i_data};
      o_valid <= 1'b1;
    end
  end

  assign o_data = acc;
endmodule