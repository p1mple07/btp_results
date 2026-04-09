     always @(*) begin
         if (state == ENTRY_PROCESSING) begin
             entry_time[current_slot] <= current_time; // Non-blocking assignment
         end
     end
     