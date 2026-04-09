always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
        for (i = 0; i < NINDEXES; i++) begin
            fifo_array[i] <= $clog2(NWAYS)'(0);
        end
    end else begin
        if (!hit) begin // Change the condition to check for miss (hit = 0)
            // Set the fifo_array position for the next replacement
            fifo_array[index] <= fifo_array[index] + $clog2(NWAYS)'(1);
        end
    end
end
