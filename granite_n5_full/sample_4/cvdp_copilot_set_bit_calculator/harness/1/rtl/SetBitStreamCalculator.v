module SetBitStreamCalculator (
  input logic i_clk, 
  input logic i_ready, 
  input logic i_rst_n, 
  input logic [0:0] i_bit_in, 
  output logic [7:0] o_set_bit_count
);

  parameter integer p_max_set_bit_count_width = 8;

  logic [7:0] l_set_bit_count;

  always @(posedge i_clk) begin
    if (i_ready) begin
      if (l_set_bit_count < p_max_set_bit_count_width - 1) begin
        if (i_bit_in == 1'b1) begin
          l_set_bit_count <= l_set_bit_count + 1;
        end
      end
    end else begin
      l_set_bit_count <= 8'h00;
    end
  end

  always @(negedge i_rst_n or posedge i_clk) begin
    if (!i_rst_n) begin
      l_set_bit_count <= 8'h00;
    end
  end

  assign o_set_bit_count = l_set_bit_count;

endmodule