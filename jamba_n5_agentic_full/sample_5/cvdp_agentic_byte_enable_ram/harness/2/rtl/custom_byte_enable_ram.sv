module top;
  parameter XLEN = 32;
  parameter LINES = 8192;
  localparam ADDR_WIDTH = $clog2(LINES);

  logic [ADDR_WIDTH-1:0] addr_a, addr_b;
  logic en_a, en_b;
  logic [XLEN/8-1:0] be_a, be_b;
  logic [XLEN-1:0] data_in_a, data_in_b;
  logic [XLEN-1:0] data_out_a, data_out_b;

  logic [XLEN-1:0] ram [LINES-1:0];

  initial begin
    for (int i = 0; i < LINES; i++) begin
      for (int j = 0; j < XLEN; j++) begin
        ram[i][j] = 0;
      end
    end
  end

  always @(posedge clk) begin
    addr_a <= addr_a_reg;
    en_a <= en_a_reg;
    be_a <= be_a_reg;
    data_in_a <= data_in_a_reg;

    addr_b <= addr_b_reg;
    en_b <= en_b_reg;
    be_b <= be_b_reg;
    data_in_b <= data_in_b_reg;
  end

  always @(*) begin
    if (en_a && addr_a[ADDR_WIDTH-1:0] == addr_a) begin
      ram[addr_a] <= data_in_a;
    end
    if (en_b && addr_b[ADDR_WIDTH-1:0] == addr_b) begin
      ram[addr_b] <= data_in_b;
    end
  end
endmodule
