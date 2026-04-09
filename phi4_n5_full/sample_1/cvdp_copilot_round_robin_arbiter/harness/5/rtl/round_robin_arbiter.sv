module round_robin_arbiter #(
    parameter N       = 4,
    parameter TIMEOUT = 16  // Default timeout value (configurable)
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,               
    input  wire [N-1:0]     priority_level,    // 1 = high priority, 0 = low priority
    output reg  [N-1:0]     grant,             // One-hot grant signal
    output reg             idle                // 1 when no active requests
);

   // Pointer for round-robin arbitration (using log2(N) bits)
   reg [$clog2(N)-1:0] pointer;
   reg [$clog2(N)-1:0] pointer_next;
   reg found;
   integer i;

   // Timeout counters for each channel (32-bit counters)
   reg [31:0] timeout_counter [0:N-1];

   // Combinational block: Determine grant signal and update pointer_next.
   // Also compute the idle signal.
   always @(*) begin
       // If no request is active, idle = 1; otherwise idle = 0.
       idle = ~(|req);
       grant = {N{1'b0}};
       pointer_next = pointer;
       found = 1'b0;

       // First, search for channels with effective high priority.
       // Effective high priority is defined as:
       //    (priority_level == 1) OR (timeout_counter >= TIMEOUT)
       for (i = 0; i < N; i = i + 1) begin
           int idx = (pointer + i) % N;
           if (!found && req[idx] == 1) begin
               if (priority_level[idx] == 1 || timeout_counter[idx] >= TIMEOUT) begin
                   grant[idx] = 1'b1;
                   pointer_next = (pointer + i + 1) % N;
                   found = 1'b1;
               end
           end
       end

       // If no high-priority (or timed-out) channel is found, 
       // then search for low-priority channels.
       if (!found) begin
           for (i = 0; i < N; i = i + 1) begin
               int idx = (pointer + i) % N;
               if (!found && req[idx] == 1) begin
                   // Only consider as low priority if the timeout counter has not expired.
                   if (priority_level[idx] == 0 && timeout_counter[idx] < TIMEOUT) begin
                       grant[idx] = 1'b1;
                       pointer_next = (pointer + i + 1) % N;
                       found = 1'b1;
                   end
               end
           end
       end
   end

   // Sequential block: Update pointer and timeout counters.
   always @(posedge clk or negedge rstn) begin
       if (!rstn) begin
           pointer <= 0;
           integer j;
           for (j = 0; j < N; j = j + 1) begin
               timeout_counter[j] <= 0;
           end
       end else begin
           pointer <= pointer_next;
           
           // For each channel, update its timeout counter.
           // If a channel's request is active (req) and it is not granted,
           // increment its timeout counter. Otherwise, reset it to 0.
           for (i = 0; i < N; i = i + 1) begin
               if (req[i] == 1 && grant[i] == 0) begin
                   if (timeout_counter[i] < TIMEOUT - 1)
                       timeout_counter[i] <= timeout_counter[i] + 1;
                   else
                       timeout_counter[i] <= TIMEOUT; // Saturate at TIMEOUT
               end else begin
                   timeout_counter[i] <= 0;
               end
           end
       end
   end

endmodule