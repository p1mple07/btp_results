module cvdp_sram_fd #(
   parameter DATA_WIDTH = 8,
   parameter ADDR_WIDTH = 4
   )(
   input                         clk     , // clock input
   input                         ce      , // chip enable
   input                         a_we    , // channel A write enable
   input                         a_oe    , // channel A output enable
   input        [ADDR_WIDTH-1:0] a_addr  , // channel A address
   input        [DATA_WIDTH-1:0] a_wdata , // channel A write data
   output logic [DATA_WIDTH-1:0] a_rdata , // channel A read data out
   input                         b_we    , // channel B write enable
   input                         b_oe    , // channel B output enable
   input        [ADDR_WIDTH-1:0] b_addr  , // channel B address
   input        [DATA_WIDTH-1:0] b_wdata , // channel B write data
   output logic [DATA_WIDTH-1:0] b_rdata   // channel B read data out
);

   localparam RAM_DEPTH  = 1 << ADDR_WIDTH;
  
   logic [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1]; 
  
   always_ff @ (posedge clk) begin
      if (ce) begin
         if (a_we) begin
     	    mem[a_addr] <= a_wdata;
         end else if (a_oe) begin
            a_rdata     <= mem[a_addr];
		 end
	  end 
   end
   
   always_ff @ (posedge clk) begin
      if (ce) begin
         if (b_we) begin
		    mem[b_addr] <= b_wdata;
         end else if (b_oe) begin 
		    b_rdata     <= mem[b_addr];
		 end
      end
   end
  
endmodule