module sync_lifo #
  (
   parameter DATA_WIDTH = 8,
   parameter ADDR_WIDTH = 3
   )
  (
   input  logic         clock,
   input  logic         reset,
   input  logic         write_en,
   input  logic         read_en,
   input  logic [DATA_WIDTH-1:0] data_in,
   output logic         empty,
   output logic         full,
   output logic [DATA_WIDTH-1:0] data_out
   );

   // Memory array for LIFO storage
   reg [DATA_WIDTH-1:0] mem [0: (1<<ADDR_WIDTH)-1];

   // Stack pointer (points to the top of the LIFO)
   reg [ADDR_WIDTH-1:0] sp;

   // Registered output for data_out
   reg [DATA_WIDTH-1:0] data_out_reg;
   assign data_out = data_out_reg;

   // Combinational flags for empty and full conditions
   assign empty = (sp == 0);
   assign full  = (sp == ((1<<ADDR_WIDTH)-1));

   // Synchronous operations on rising edge of clock
   always_ff @(posedge clock) begin
      if (reset) begin
         // Synchronous reset: clear stack pointer, output, and memory array
         sp                    <= 0;
         data_out_reg          <= '0;
         integer i;
         for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
            mem[i]             <= '0;
      end
      else begin
         // Use an intermediate variable for stack pointer updates
         integer next_sp;
         next_sp = sp;  // Default: no change

         // Write operation: push new data if not full
         if (write_en && !full) begin
            mem[sp] <= data_in;
            next_sp = sp + 1;
         end

         // Read operation: pop data if not empty
         if (read_en && !empty) begin
            // Use the updated pointer (if push occurred) for pop operation
            data_out_reg <= mem[next_sp];
            next_sp = next_sp - 1;
         end

         // Update the stack pointer
         sp <= next_sp;
      end
   end

endmodule