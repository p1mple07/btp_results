always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        // Initialize registers to default values
        priority_map <= {32{1'b0}};
        interrupt_mask <= {32{1'b1}};
        vector_table <= {32{1'b0}};
        pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
        interrupt_service <= 0;
        cpu_interrupt => 0;
        cpu_ack => 0;
        interrupt_idx => 0;
        interrupt_vector => 0;
    end else begin
        // Main processing
        // ...
    end
end
