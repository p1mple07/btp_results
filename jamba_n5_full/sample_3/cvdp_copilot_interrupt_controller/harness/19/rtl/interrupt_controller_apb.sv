logic [NUM_INTERRUPTS-1:0] priority_map;
logic [NUM_INTERRUPTS-1:0] interrupt_mask;
logic [NUM_INTERRUPTS-1:0] vector_table[0:ADR_WIDTH*NUM_INTERRUPTS-1];
logic pending_interrupts;
