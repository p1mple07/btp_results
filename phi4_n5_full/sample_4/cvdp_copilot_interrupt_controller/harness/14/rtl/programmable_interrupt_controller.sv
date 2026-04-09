module interrupt_controller 
#(
    parameter NUM_INTERRUPTS = 4, 
    parameter ADDR_WIDTH = 8
)
(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
    output logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    input  logic [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

    // Internal registers to track pending and current interrupts
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] current_interrupt;
    logic [$clog2(NUM_INTERRUPTS)-1:0] current_interrupt_idx;
    logic [ADDR_WIDTH-1:0] current_vector;
    
    // Internal registers for dynamic updates
    logic [NUM_INTERRUPTS-1:0] priority_map;
    logic [ADDR_WIDTH-1:0] vector_table [NUM_INTERRUPTS-1:0];
    logic [NUM_INTERRUPTS-1:0] interrupt_mask;
    
    // Output assignments
    assign interrupt_service = current_interrupt;
    assign cpu_interrupt      = (|current_interrupt); // Assert high if any interrupt is being serviced
    assign interrupt_idx      = current_interrupt_idx;
    assign interrupt_vector   = current_vector;
    
    // Main sequential block for state updates and dynamic configuration
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all internal registers
            pending_interrupts      <= '0;
            current_interrupt       <= '0;
            current_interrupt_idx   <= '0;
            current_vector          <= '0;
            
            // Initialize priority map with default sequential priorities
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                priority_map[i] <= i;
            end
            
            // Initialize vector table with default vectors as multiples of 4
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                vector_table[i] <= i * 4;
            end
            
            // Initialize interrupt mask (no interrupts masked by default)
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                interrupt_mask[i] <= 1'b0;
            end
        end
        else begin
            // Dynamic update of the priority map
            if (priority_map_update) begin
                // Assuming the new priority for each interrupt is provided in the first element of each row
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    priority_map[i] <= priority_map_value[i][0];
                end
            end
            
            // Dynamic update of the vector table
            if (vector_table_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    vector_table[i] <= vector_table_value[i];
                end
            end
            
            // Dynamic update of the interrupt mask
            if (interrupt_mask_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    interrupt_mask[i] <= interrupt_mask_value[i];
                end
            end
            
            // Update pending interrupts: set a bit if a new interrupt request is received and not already pending
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (interrupt_requests[i] && !pending_interrupts[i])
                    pending_interrupts[i] <= 1'b1;
            end
            
            // If the CPU has acknowledged servicing the current interrupt, clear it and its pending flag
            if (cpu_ack && current_interrupt) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    if (current_interrupt[i])
                        pending_interrupts[i] <= 1'b0;
                end
                current_interrupt    <= '0;
                current_interrupt_idx<= '0;
                current_vector       <= '0;
            end
            else begin
                // If no current interrupt is being serviced, select the highest priority pending interrupt that is not masked.
                if (!current_interrupt) begin
                    int selected = -1;
                    for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                        if (pending_interrupts[i] && !interrupt_mask[i]) begin
                            // Select the interrupt with the lowest priority value (i.e. highest priority)
                            if (selected == -1 || (priority_map[i] < priority_map[selected]))
                                selected = i;
                        end
                    end
                    if (selected != -1) begin
                        // Set the current interrupt to be serviced
                        current_interrupt    <= (1 << selected);
                        current_interrupt_idx<= selected;
                        current_vector       <= vector_table[selected];
                    end
                end
            end
        end
    end

endmodule