module cascaded_adder #(
  parameter IN_DATA_WIDTH = 16,
  parameter IN_DATA_NS = 4
) (
  input  wire clk,
  input  wire rst_n,
  input  wire i_valid,
  input  wire [`IN_DATA_WIDTH * `IN_DATA_NS - 1 : 0] i_data,
  output reg  o_valid,
  output reg [`IN_DATA_WIDTH + $clog2(`IN_DATA_NS) - 1 : 0] o_data
);

  // Local parameters and variables
  localparam STAGES = $clog2(`IN_DATA_NS);
  localparam OUTPUT_WIDTH = `IN_DATA_WIDTH + $clog2(`IN_DATA_NS);

  reg [OUTPUT_WIDTH - 1 : 0] accu;
  reg [IN_DATA_WIDTH - 1 : 0] input_reg;

  // Combinational Logic
  always @(*) begin
    if (rst_n == 1'b0) begin
      accu <= {OUTPUT_WIDTH{1'b0}};
      input_reg <= {IN_DATA_WIDTH{1'b0}};
    end else begin
      if (i_valid == 1'b1) begin
        accu <= {accu[OUTPUT_WIDTH - 1 : STAGES], i_data};
        input_reg <= i_data;
      end
    end
  end

  // Sequential Logic
  always @(posedge clk) begin
    if (rst_n == 1'b0) begin
      o_valid <= 1'b0;
      o_data <= {OUTPUT_WIDTH{1'b0}};
    end else begin
      if (input_reg!= {IN_DATA_WIDTH{1'b0}}) begin
        o_valid <= 1'b1;
        o_data <= accu;
      end else begin
        o_valid <= 1'b0;
        o_data <= {OUTPUT_WIDTH{1'b0}};
      end
    end
  end

endmodule