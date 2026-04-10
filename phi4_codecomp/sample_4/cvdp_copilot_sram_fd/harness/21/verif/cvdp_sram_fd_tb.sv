`timescale 1ns/1ns
module cvdp_sram_fd_tb ();
   
   localparam DATA_WIDTH = 8;
   localparam ADDR_WIDTH = 4;
   localparam RAM_DEPTH  = 1 << ADDR_WIDTH;
   
   logic  clk, ce, a_we, b_we, a_oe, b_oe;
   logic  [DATA_WIDTH-1:0] a_wdata;  // Write data for Port A
   logic  [DATA_WIDTH-1:0] a_rdata;  // Read data from Port A
   logic  [ADDR_WIDTH-1:0] a_addr;   // Address for Port A
   logic  [DATA_WIDTH-1:0] b_wdata;  // Write data for Port B
   logic  [DATA_WIDTH-1:0] b_rdata;  // Read data from Port B
   logic  [ADDR_WIDTH-1:0] b_addr;   // Address for Port B
   logic  [DATA_WIDTH-1:0] RAM [0:RAM_DEPTH-1]; // Reference memory for verification
   
   logic [DATA_WIDTH-1:0] prev_data;
   logic [DATA_WIDTH-1:0] prev_a_rdata, prev_b_rdata;

cvdp_sram_fd
   #( .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
   ) DUT (
      .clk           (clk),
      .ce            (ce),
      .a_we          (a_we),
      .a_oe          (a_oe),
      .a_addr        (a_addr),
      .a_wdata       (a_wdata),
      .a_rdata       (a_rdata),
      .b_we          (b_we),
      .b_oe          (b_oe),
      .b_addr        (b_addr),
      .b_wdata       (b_wdata),
      .b_rdata       (b_rdata)
   );

   initial begin
      clk = 0;
      forever #5 clk = ~clk; 
   end
   
   // VCD Dump
   initial begin
      $dumpfile("cvdp_sram_fd_tb_1.vcd");
      $dumpvars(0, cvdp_sram_fd_tb);
   end
   
   initial begin
      ce     = 0;
      a_we   = 0;
      b_we   = 0;
      a_oe   = 0;
      b_oe   = 0;
      a_addr = 0;
      b_addr = 0;
      a_wdata= 0;
      b_wdata= 0;
      
      for (int i = 0; i < RAM_DEPTH; i++) begin
         RAM[i] = 'bx;
      end

      repeat(2) @(posedge clk);

      test_0();
      
      test_1();

      test_2();

      test_3();

      test_4();

      test_5();

      test_6();

      test_7();

      test_8();

      test_9();

      test_10();

      $display("\nAll tests completed successfully.");
      $finish();
   end

   task test_0();
      begin
         $display("\nTest 0");
         @(negedge clk);
         ce      = 1;
         a_we    = 0;
         a_oe    = 1;
         a_addr  = $random();
         
         @(posedge clk);
         @(posedge clk);
         
         if ($isunknown(a_rdata)) begin
            $display("Initial memory content is undefined as expected at Addr=%h", a_addr);
         end else begin
            $display("Warning: Initial memory content is defined at Addr=%h, Data=%h", a_addr, a_rdata);
         end
      end
   endtask

   task test_1();
      begin
         $display("\nTest 1");
         @(negedge clk);
         ce      = 0;
         a_we    = 1;
         a_oe    = 1;
         b_we    = 1;
         b_oe    = 1;
         a_addr  = $random();
         b_addr  = $random();
         a_wdata = $random();
         b_wdata = $random();
         
         @(posedge clk); 
         @(posedge clk); 
         
         if (a_rdata !== 0 || b_rdata !== 0) begin
            $display("Error: Outputs are not zero when ce is low. a_rdata=%h, b_rdata=%h", a_rdata, b_rdata);
         end else begin
            $display("Outputs are as expected.");
         end
      end
   endtask

   task test_2();
      begin
         $display("\nTest 2");
         @(negedge clk);
         ce      = 1;
         a_we    = 1;
         a_oe    = 0;
         a_addr  = $random();
         a_wdata = $random();
         
         @(posedge clk); 
         @(posedge clk); 
         RAM[a_addr] = a_wdata; 
         
         if (DUT.mem[a_addr] !== a_wdata) begin
            $display("Error: Write operation failed on Port A. Addr=%h, Expected=%h, Actual=%h", a_addr, a_wdata, DUT.mem[a_addr]);
         end else begin
            $display("Write operation successful on Port A. Addr=%h, Data=%h", a_addr, a_wdata);
         end
         
         @(negedge clk);
         a_we    = 0;
         a_oe    = 1;
         
         @(posedge clk); 
         @(posedge clk); 
         
         if (a_rdata !== RAM[a_addr]) begin
            $display("Error: Read operation failed on Port A. Addr=%h, Expected=%h, Actual=%h", a_addr, RAM[a_addr], a_rdata);
         end else begin
            $display("Read operation successful on Port A. Addr=%h, Data=%h", a_addr, a_rdata);
         end
      end
   endtask

   task test_3();
      begin
         $display("\nTest 3");
         @(negedge clk);
         ce      = 1;
         b_we    = 1;
         b_oe    = 0;
         b_addr  = $random();
         b_wdata = $random();
         
         @(posedge clk); 
         @(posedge clk); 
         RAM[b_addr] = b_wdata; 
         
         if (DUT.mem[b_addr] !== b_wdata) begin
            $display("Error: Write operation failed on Port B. Addr=%h, Expected=%h, Actual=%h", b_addr, b_wdata, DUT.mem[b_addr]);
         end else begin
            $display("Write operation successful on Port B. Addr=%h, Data=%h", b_addr, b_wdata);
         end
         
         @(negedge clk);
         b_we    = 0;
         b_oe    = 1;
         
         @(posedge clk);
         @(posedge clk);
         
         if (b_rdata !== RAM[b_addr]) begin
            $display("Error: Read operation failed on Port B. Addr=%h, Expected=%h, Actual=%h", b_addr, RAM[b_addr], b_rdata);
         end else begin
            $display("Read operation successful on Port B. Addr=%h, Data=%h", b_addr, b_rdata);
         end
      end
   endtask

   task test_4();
      begin
         $display("\nTest 4");
         @(negedge clk);
         ce      = 1;
         a_we    = 1;
         a_oe    = 1; 
         a_addr  = $random();
         a_wdata = $random();
         prev_data = DUT.mem[a_addr];
         
         @(posedge clk); 
         @(posedge clk); 
         RAM[a_addr] = a_wdata; 
         
         if (a_rdata !== prev_data) begin
            $display("Error: Read-first behavior failed on Port A. Addr=%h, Expected=%h, Actual=%h", a_addr, prev_data, a_rdata);
         end else begin
            $display("Read-first behavior successful on Port A. Addr=%h, Read Data=%h", a_addr, a_rdata);
         end
         
         if (DUT.mem[a_addr] !== a_wdata) begin
            $display("Error: Write operation failed on Port A. Addr=%h, Expected=%h, Actual=%h", a_addr, a_wdata, DUT.mem[a_addr]);
         end else begin
            $display("Write operation successful on Port A. Addr=%h, Data=%h", a_addr, a_wdata);
         end
      end
   endtask

   task test_5();
      begin
         $display("\nTest 5");
         @(negedge clk);
         ce      = 1;
         a_we    = 1;
         a_oe    = 0;
         b_we    = 0;
         b_oe    = 1;
         a_addr  = $random();
         b_addr  = $random();
         a_wdata = $random();
         while(a_addr == b_addr) begin
			b_addr  = $random();
		 end
         if ($isunknown(DUT.mem[b_addr])) begin
            RAM[b_addr] = $random();
            DUT.mem[b_addr] = RAM[b_addr];
         end
		 
         @(posedge clk); 
         @(posedge clk); 
         RAM[a_addr] = a_wdata; 
         
         if (DUT.mem[a_addr] !== a_wdata) begin
            $display("Error: Write operation failed on Port A. Addr=%h, Expected=%h, Actual=%h", a_addr, a_wdata, DUT.mem[a_addr]);
         end else begin
            $display("Write operation successful on Port A. Addr=%h, Data=%h", a_addr, a_wdata);
         end
         
         if (b_rdata !== RAM[b_addr]) begin
            $display("Error: Read operation failed on Port B. Addr=%h, Expected=%h, Actual=%h", b_addr, RAM[b_addr], b_rdata);
         end else begin
            $display("Read operation successful on Port B. Addr=%h, Data=%h", b_addr, b_rdata);
         end
      end
   endtask

   task test_6();
      begin
         $display("\nTest 6");
         @(negedge clk);
         ce      = 1;
         a_we    = 0;
         a_oe    = 1;
         b_we    = 1;
         b_oe    = 0;
         a_addr  = $random();
         b_addr  = a_addr;
         b_wdata = $random();
         prev_data = DUT.mem[a_addr];
         
         @(posedge clk); 
         @(posedge clk); 
         RAM[b_addr] = b_wdata; 
         
         if (a_rdata !== prev_data) begin
            $display("Error: Read operation failed on Port A. Addr=%h, Expected=%h, Actual=%h", a_addr, prev_data, a_rdata);
         end else begin
            $display("Read operation successful on Port A. Addr=%h, Data=%h", a_addr, a_rdata);
         end
         
         if (DUT.mem[b_addr] !== b_wdata) begin
            $display("Error: Write operation failed on Port B. Addr=%h, Expected=%h, Actual=%h", b_addr, b_wdata, DUT.mem[b_addr]);
         end else begin
            $display("Write operation successful on Port B. Addr=%h, Data=%h", b_addr, b_wdata);
         end
      end
   endtask

   task test_7();
      begin
         $display("\nTest 7");
         @(posedge clk); 
         @(posedge clk); 
         prev_a_rdata = a_rdata;
         prev_b_rdata = b_rdata;
         
         @(negedge clk);
         ce      = 1;
         a_we    = 0;
         a_oe    = 0;
         b_we    = 0;
         b_oe    = 0;
         a_addr  = $random();
         b_addr  = $random();
         
         @(posedge clk); 
         @(posedge clk); 
         
         if (a_rdata !== prev_a_rdata) begin
            $display("Error: Port A output changed without operation.Prev=%h, Current=%h", prev_a_rdata, a_rdata);
         end else begin
            $display("Port A output remains unchanged as expected.");
         end
         if (b_rdata !== prev_b_rdata) begin
            $display("Error: Port B output changed without operation. Prev=%h, Current=%h", prev_b_rdata, b_rdata);
         end else begin
            $display("Port B output remains unchanged as expected.");
         end
      end
   endtask

   task test_8();
      begin
         $display("\nTest 8");
         @(negedge clk);
         ce      = 1;
         a_we    = 1;
         a_oe    = 0;
         a_addr  = 0;
         a_wdata = $random();
         
         @(posedge clk);
         @(posedge clk);
         RAM[a_addr] = a_wdata; 
         
         if (DUT.mem[a_addr] !== a_wdata) begin
            $display("Error: Write failed at minimum address on Port A.");
         end else begin
            $display("Write successful at minimum address on Port A.");
         end
         
         @(negedge clk);
         a_we    = 0;
         b_we    = 1;
         b_oe    = 0;
         b_addr  = RAM_DEPTH - 1;
         b_wdata = $random();
         
         @(posedge clk);
         @(posedge clk);
         RAM[b_addr] = b_wdata; 
         
         if (DUT.mem[b_addr] !== b_wdata) begin
            $display("Error: Write failed at maximum address on Port B.");
         end else begin
            $display("Write successful at maximum address on Port B.");
         end
      end
   endtask

   task test_9();
      begin
         $display("\nTest 9");
         @(negedge clk);
         ce      = 1;
         a_we    = 1;
         a_oe    = 0;
         a_addr  = $random();
         a_wdata = $random();
         RAM[a_addr] = a_wdata;
         
         @(posedge clk);
         @(posedge clk);
         
         @(negedge clk);
         a_we    = 0;
         a_oe    = 0;
         
         @(posedge clk); 
         @(posedge clk); 
         
         @(negedge clk);
         a_oe    = 1;
         
         @(posedge clk); 
         @(posedge clk); 
         
         if (a_rdata !== RAM[a_addr]) begin
            $display("Error: Data retention failed. Expected=%h, Actual=%h", RAM[a_addr], a_rdata);
         end else begin
            $display("Data retention successful. Data=%h", a_rdata);
         end
      end
   endtask

   task test_10();
      begin
         $display("\nTest 10");
         @(negedge clk);
         ce      = 0;
         a_oe    = 1;
         b_oe    = 1;
         
         @(posedge clk);
         @(posedge clk);
         
         if (a_rdata !== 0 || b_rdata !== 0) begin
            $display("Error: Outputs are not zero. a_rdata=%h, b_rdata=%h", a_rdata, b_rdata);
         end else begin
            $display("Outputs are zero as expected.");
         end
      end
   endtask

endmodule