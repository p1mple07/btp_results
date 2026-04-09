assign out_err_plus2_o = valid_out_i ? 
    (err_unaligned && !err_q[0]) |
    (in_err_i && !err_q[0]) |
    (err_q[0] ? ~err_q[0] : 0) :
    0;

assign rdata_d[i] = valid_q[i] ? rdata_q[i] : in_rdata_i;
assign err_d[i] = valid_q[i] ? err_q[i] : in_err_i;

always @(*) begin
    if (valid_out_i || !rst_i) {
        if (!rst_i) {
            // Compute new_err_plus2 based on current state
            err_plus2 = (err_q[0] || in_err_i) ? (err_q[0] ? 1 : (err_q[1] ? 1 : 0)) : 0;
        }
    }
end

always @(*) begin
    if (rst_i) {
        // Initialize registers with '0'
    } else if (in_clear_i) {
        // Update base address
    } else {
        // Determine valid entries and select from FIFO
        if (valid_out_i) {
            out_addr_o = out_valid_o ? base_add ? addr_incr_two : addr_incr_one : addr_incr_one;
        }
    }
end

// Add this condition to the pop logic
if (!rst_i && !valid_out_i && out_ready_i && !out_valid_o) {
    if (!compressed) {
        pop_fifo();
    }
}

always @(*) begin
    if (!rst_i) {
        if (valid_in && clear_i) {
            load_fifo();
        }
    }
end

assign out_err_plus2_o = valid_out_i ? 
       (err_unaligned && !err_q[0]) |
       (in_err_i && !err_q[0]) |
       (err_q[0] ? ~err_q[0] : 0) :
       0;

assign rdata_d[i] = valid_q[i] ? rdata_q[i] : in_rdata_i;
   assign err_d[i] = valid_q[i] ? err_q[i] : in_err_i;

always @(*) begin
       if (valid_out_i || !rst_i) {
           if (!rst_i) {
               if (!rst_i) {
                   // New calculation based on valid state
                   if (!rst_i) {
                       integer temp = 0;
                       if (err_d[0] && !err_d[1]) {
                           temp = 1;
                       }
                       err_plus2 = temp;
                   }
               }
           }
       }
   end

always @(*) begin
       if (rst_i) {
           valid_q[...] = 1;
       } else if (in_clear_i) {
           clear_q[...] = 1;
       } else {
           if (valid_q[0] && !rst_i) {
               base_add = clear_i ? 1 : (in_valid_i & !unaligned_is_compressed);
               // Adjust address accordingly
           }
       }
   end

// Add this condition to the pop logic
   if (!rst_i && !valid_out_i && out_ready_i && !out_valid_o) {
       if (!compressed) {
           pop_fifo();
       }
   }

always @(*) begin
       if (!rst_i) {
           if (valid_in && clear_i) {
               load_fifo();
           }
       }
   end