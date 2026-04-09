module sdram_controller (clk,reset,addr,data_in,data_out,read,write,sdram_clk,sdram_cke,sdram_cs,sdram_ras,sdram_cas,sdram_we,sdram_addr,sdram_ba,sdram_dq,dq_out);
   // Define parameters and signals
   parameter CLK_PERIOD = 10; // define clock period in nanoseconds
   parameter REFRESH_TIME = 1024; // define refresh time in number of clock cycles

   reg [7:0] addr_reg; // register for address
   reg [31:0] data_reg; // register for data
   reg [31:0] data_out_reg; // register for output data
   reg [15:0] dq_out_reg; // register for DQ output
   
   // Initialize registers
   initial begin
      addr_reg <= 8'h00; // initialize address register
      data_reg <= 32'h0000000; // initialize data register
      data_out_reg <= 32'h0000000; // initialize output data register
      dq_out_reg <= 16'h0000; // initialize DQ output register
   end

   // Implement the FSM logic
   always @(posedge clk or posedge reset) begin
      if (reset) begin
         // Reset FSM state and registers
         addr_reg <= 8'h00;
         data_reg <= 32'h0000000;
         data_out_reg <= 32'h0000000;
         dq_out_reg <= 16'h0000;
         state <= IDLE;
      end else begin
         case (state)
            IDLE: begin
               // Monitor for read or write requests
               if (read || write) begin
                  state <= ACTIVATE;
                  // Issue Activate Command
                  cs_n <= 1'b0;
                  ras_n <= 1'b1;
                  cas_n <= 1'b1;
                  we_n <= 1'b0;
                  // Wait for activate command to complete
                  #(CLK_PERIOD * REFRESH_TIME);
               end
            end
            ACTIVATE: begin
               // Issue Activate Command
               cs_n <= 1'b0;
               ras_n <= 1'b1;
               cas_n <= 1'b1;
               we_n <= 1'b0;
               // Wait for activate command to complete
               #(CLK_PERIOD * REFRESH_TIME);
               if (read || write) begin
                  state <= READ_WRITE;
               }
            end
            READ_WRITE: begin
               // Issue Read Command
               cs_n <= 1'b0;
               cke_n <= 1'b1;
               ras_n <= 1'b0;
               cas_n <= 1'b1;
               we_n <= 1'b0;
               // Wait for read or write command to complete
               #(CLK_PERIOD * REFRESH_TIME);
               if (!read &&!write) begin
                  state <= IDLE;
               end
            end
         endcase
      end
   end

   // Implement the Read Command
   always @(posedge clk) begin
      if (read) begin
         // Issue Read Command
         cs_n <= 1'b0;
         cke_n <= 1'b1;
         ras_n <= 1'b0;
         cas_n <= 1'b1;
         we_n <= 1'b0;
         // Data path
         data_reg <= #CLK_PERIOD sdram_dq;
         // Output data
         data_out_reg <= #CLK_PERIOD data_reg;
      end
   end

   // Implement the Write Command
   always @(posedge clk) begin
      if (write) begin
         // Issue Write Command
         cs_n <= 1'b0;
         cke_n <= 1'b1;
         ras_n <= 1'b1;
         cas_n <= 1'b0;
         we_n <= 1'b1;
         // Data path
         data_reg <= #CLK_PERIOD data_in;
         dq_out_reg <= #CLK_PERIOD sdram_dq;
      end
   end

endmodule