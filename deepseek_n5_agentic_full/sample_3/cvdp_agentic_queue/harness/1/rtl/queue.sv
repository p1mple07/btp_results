Module Declaration
 module queue (
     // Ports
     // Clock and Reset
     clk_i,
     rst_ni,
     clr_i,
     // Control Signals
     ena_i,
     re_i,
     // Data Input
     we_i,
     d_i,
     // Data Output
     q_o,
     // Status Signals
     empty_o,
     full_o,
     almost_empty_o,
     almost_full_o );

     // Internal Structures
     // Queue Data Storage
     queue_data[(queue_wadr + DEPTH - 1)][DBITS] queue_data;
     queue_wadr queue_wadr;

     // Variables
     integer Qempty_o, Full_o, almost_empty_o, almost_full_o;

     // Initialization
     initialize();
     // Main Logic
     always(clk_i positiveedge) begin
         // Write-Only Operation
         if (we_i && !ena_i) begin
             queue_data[pointer][dbits-1] = d_i;
         end

         // Read-Only Operation
         else if (re_i && !ena_i) begin
             if (queue_wadr > 0) begin
                 // Shift operation
                 q_o = queue_data[queue_wadr - 1];
                 queue_wadr -= 1;
             else 
                 q_o = 0;
         end

         // Simultaneous Read/Write Operation
         else if (we_i && re_i && !ena_i) begin
             if (queue_wadr == 0) begin
                 // First-word-fall-through
                 queue_data[0] = d_i;
                 q_o = queue_data[0];
             else 
                 // Shift and write
                 q_o = queue_data[queue_wadr - 1];
                 queue_wadr -= 1;
                 queue_data[queue_wadr] = d_i;
         end

         // Update status signals
         if (empty_o) queue_wadr == 0;
         if (full_o) queue_wadr == DEPTH - 1;
         almost_empty_o = queue_wadr < ALMOST_EMPTY_THRESHOLD;
         almost_full_o = queue_wadr >= ALMOST_FULL_THRESHOLD;
     end

     // Setup Outputs
     q_o = q_o;
     empty_o = empty_o;
     full_o = full_o;
     almost_empty_o = almost_empty_o;
     almost_full_o = almost_full_o;
 endmodule