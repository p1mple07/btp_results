module data_width_converter(
  // Clock and Reset
  input wire clk,
  input wire reset,

  // Input Ports
  input wire [31:0] data_in,
  input wire data_valid,

  // Output Ports
  output wire [127:0] o_data_out,
  output reg o_data_out_valid
);

  // Internal State Registers
  reg [31:0] data_reg[3:0];
  reg [2:0] count_reg;
  reg valid_reg;

  // Combinational Logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      count_reg <= 0;
      valid_reg <= 0;
    end else begin
      if (data_valid &&!valid_reg) begin
        data_reg[count_reg] <= data_in;
        count_reg <= count_reg + 1;
      end

      if (count_reg == 3 && valid_reg) begin
        o_data_out <= {data_reg[2], data_reg[1], data_reg[0]};
        o_data_out_valid <= 1;

        count_reg <= 0;
        valid_reg <= 0;
      end
    end
  end

endmodule