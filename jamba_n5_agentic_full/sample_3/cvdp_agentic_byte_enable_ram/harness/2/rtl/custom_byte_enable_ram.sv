module custom_byte_enable_ram (
    input  wire clk,
    input  wire addr_a,
    input  wire en_a,
    input  wire be_a,
    input  wire data_in_a,
    input  wire addr_b,
    input  wire en_b,
    input  wire be_b,
    input  wire data_in_b,
    input  wire addr_b_dup,  // not used
    output reg [XLEN-1:0] data_out_a,
    output reg [XLEN-1:0] data_out_b
);

  localparam ADDR_WIDTH = $clog2(LINES);
  reg [ADDR_WIDTH-1:0] addr_a_reg, addr_b_reg;
  reg [XLEN/8-1:0] be_a_reg, be_b_reg;
  reg [XLEN-1:0] data_in_a_reg, data_in_b_reg;
  reg [XLEN-1:0] data_out_a_reg, data_out_b_reg;

  always @(posedge clk) begin
    addr_a_reg <= addr_a;
    en_a_reg <= en_a;
    be_a_reg <= be_a;
    data_in_a_reg <= data_in_a;

    addr_b_reg <= addr_b;
    en_b_reg <= en_b;
    be_b_reg <= be_b;
    data_in_b_reg <= data_in_b;
  end

  always @(addr_a_reg or addr_b_reg or en_a_reg or en_b_reg) begin
    if (addr_a_reg == addr_b_reg) begin
      if (en_a_reg && en_b_reg) begin
        if (be_a_reg && be_b_reg) begin
          if (data_in_a_reg == data_in_b_reg)
            data_out_a <= data_out_a_reg;
            data_out_b <= data_out_b_reg;
          else
            data_out_a <= data_in_a_reg;
            data_out_b <= data_in_b_reg;
        end else begin
          data_out_a <= data_out_a_reg;
          data_out_b <= data_out_b_reg;
        end
      end
    end else begin
      data_out_a <= data_out_a_reg;
      data_out_b <= data_out_b_reg;
    end
  end

  always @(*) begin
    data_out_a = data_out_a_reg;
    data_out_b = data_out_b_reg;
  end

endmodule
