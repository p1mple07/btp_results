// Priority evaluation logic
always_comb begin
    if (priority_map_update) begin
        for (int i=0; i<NUM_ INTERRUPTS; i++) begin
            priority_mask[i] = ~priority_map_value[i];
        end
    end
    
    if (vector_table_update) begin
        for (int i=0; i<NUM_ INTERRUPTS; i++) begin
            vector_table[i] = vector_table_value[i];
        end
    end
    
    if (interrupt_mask_update) begin
        for (int i=0; i<NUM_ INTERRUPTS; i++) begin
            interrupt_mask[i] = ~interrupt_mask_value;
        end
    end

    // Evaluate pending interrupts
    for (int i=0; i<NUM_ INTERRUPTS; i++) begin
        pending_interrupts[i] = (priority_mask[i] & interrupt_requests) & (~interrupt_service[i]) & ~interrupt_mask[i];
    end

    // Select the highest priority interrupt
    logic [ADDR_WIDTH-1:0] highest_priority_vector;
    int max_priority_index = 0;
    for (int i=0; i<NUM_ INTERRUPTS; i++) begin
        if (pending_interrupts[i] && priority_map_value[i] > priority_map_value[max_priority_index]) begin
            max_priority_index = i;
        end
    end

    if (pending_interrupts[max_priority_index]) begin
        interrupt_vector = vector_table[max_priority_index];
        interrupt_service[max_priority_index] = 1'b1;
    end else begin
        interrupt_vector = 0;
    end
end