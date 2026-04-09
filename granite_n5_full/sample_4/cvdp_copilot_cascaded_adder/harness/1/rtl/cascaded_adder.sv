module cascaded_adder #(
  parameter IN_DATA_WIDTH = 16,
  parameter IN_DATA_NS    = 4
) (
  input  wire                    clk,
  input  wire                    rst_n,

  input  wire                    i_valid,
  input  wire [IN_DATA_WIDTH-1:0] i_data [IN_DATA_NS-1:0],

  output reg                     o_valid,
  output wire [IN_DATA_WIDTH+7:0] o_data
);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset logic here
    end else begin
      // Logic for cascaded addition process here
      // Registering the input data and output sum here
    end
  end
endmodule