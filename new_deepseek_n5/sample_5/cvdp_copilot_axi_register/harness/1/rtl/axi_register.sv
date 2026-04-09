module axi_register(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);

  input clock, rst_n;
  input [ADDR_WIDTH-1:0] awaddr, araddr;
  input [DATA_WIDTH-1:0] wdata, rdata;
  input [1:0] wstrb, rstrb;
  input [1:0] wvalid, rvalid;
  input [1:0] start, valid;
  output [1:0] beat, start_o, done_o, writeback_o, id_o;
  output [1:0] rresp, bresp;
  output [1:0] wresp, bresp;

  reg beat, start_o, done_o, writeback_o, id_o;
  reg [20-1:0] beat_reg;
  reg [32-1:0] id_reg;

  always @posedge clock begin
    if (rst_n) 
      beat = 0, start_o = 0, done_o = 0, writeback_o = 0, id_o = 0;
    else
      if (valid) 
        beat_o = beat;
      end
    end
  end

  // Write logic
  always begin
    if (wvalid && arvalid_i) begin
      awready_o = 1;
      // Process write data
      if (wstrb) begin
        beat_o = wdata;
        start_o = (wdata & 1) ? 1 : 0;
        done_o = 0;
        writeback_o = (wdata & 1) ? 1 : 0;
      end
      bvalid_o = 1;
    end
  end

  // Read logic
  always begin
    if (rvalid && arvalid_i) begin
      arready_o = 1;
      beat_o = beat_reg;
      done_o = 0;
      id_o = id_reg;
      rvalid_o = 1;
    end
  end

  // Error handling
  always begin
    if (!wvalid || !arvalid_i) 
      bresp = 2'b10;
    if (!rvalid || !arvalid_i) 
      rresp = 2'b10;
  end
endmodule