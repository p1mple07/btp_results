module ttc_counter_lite(
  input wire clk,
  input wire reset,
  input wire [3:0] axi_addr,
  input wire [31:0] axi_wdata,
  input wire axi_write_en,
  input wire axi_read_en,
  output reg [31:0] axi_rdata,
  output reg interrupt
);

  // Internal signals
  reg [31:0] count;
  reg [31:0] match_value;
  reg [31:0] reload_value;
  reg enable;
  reg interval_mode;
  reg interrupt_enable;
  reg [1:0] axi_rresp;
  reg [31:0] axi_bresp;
  
  always @(posedge clk) begin
    if (reset) begin
      count <= 0;
      match_value <= 0;
      reload_value <= 0;
      enable <= 0;
      interval_mode <= 0;
      interrupt_enable <= 0;
      interrupt <= 0;
    end else begin
      if (axi_write_en && axi_addr[1:0] == 2'b00) begin
        match_value <= axi_wdata[31:16];
        reload_value <= axi_wdata[15:0];
      end
      
      if (enable) begin
        if (interval_mode) begin
          if (count == reload_value) begin
            count <= 0;
          end
        end else begin
          if (count == match_value) begin
            count <= 0;
          end
        end
      end
      
      if (axi_addr[1:0] == 2'b00) begin
        axi_rdata <= {16{count[15]}}, count[15:0];
      end else if (axi_addr[1:0] == 2'b01) begin
        axi_rdata <= match_value;
      end else if (axi_addr[1:0] == 2'b10) begin
        axi_rdata <= reload_value;
      end else if (axi_addr[1:0] == 2'b11) begin
        axi_rdata <= {16{enable}}, interval_mode, interrupt_enable};
      end
      
      if (axi_addr[1:0] == 2'b01 && axi_write_en) begin
        interrupt <= 0;
      end
      
      if (axi_addr[1:0] == 2'b11 && axi_write_en) begin
        enable <= axi_wdata[0];
        interval_mode <= axi_wdata[1];
        interrupt_enable <= axi_wdata[2];
      end
      
    end
  end
  
  assign axi_bresp = 2'b00;
  
endmodule