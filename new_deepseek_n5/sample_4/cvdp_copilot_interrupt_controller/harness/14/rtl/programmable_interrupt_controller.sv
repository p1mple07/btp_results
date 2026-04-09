module interrupt_controller 
#(
    parameter NUM_INTERRUPTS = 4, 
    parameter ADDR_WIDTH = 8)
(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    input  logic [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

    // Initialize priority map and vector table
    logic [NUM_INTERRUPTS-1:0] priority_map = (4'b0, 4'b1, 4'b2, 4'b3);
    logic [ADDR_WIDTH-1:0] vector_table = (8'b0, 8'b0, 8'b0, 8'b0);
    
    // Internal state variables
    logic [NUM_INTERRUPTS-1:0] priority_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] interrupt_mask;
    logic current_interrupt;
    logic pending_interrupt_count;

    // Always active initialization on first clock cycle
    always @* begin
        if (rst_n) begin
            // Initialize priority map and vector table
            priority_mask = interrupt_mask;
            pending_interrupts = 0;
            interrupt_mask = interrupt_mask_value;
            
            // Find highest priority interrupt that is not masked
            current_interrupt = 0;
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if ((priority_map[i] & priority_mask[i]) == 0) begin
                    current_interrupt = i;
                    break;
                end
            end
        end
    end

    // Synchronize all ports
    clock_gating logic (clk) -> (priority_map, vector_table, interrupt_mask, current_interrupt);

    // Process interrupt handling
    always @posedge clk begin
        if (rst_n) begin
            priority_mask = interrupt_mask;
            pending_interrupts = 0;
            interrupt_mask = interrupt_mask_value;
            
            // Find highest priority interrupt that is not masked
            current_interrupt = 0;
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if ((priority_map[i] & priority_mask[i]) == 0) begin
                    current_interrupt = i;
                    break;
                end
            end
        end
        if (current_interrupt) begin
            // Service the selected interrupt
            interrupt_service = 1;
            cpu_interrupt = 1;
            
            // Update after acknowledgment
            cpu_ack = 0;
            current_interrupt = 0;
        end
    end

    // Output the selected vector
    interrupt_vector = vector_table[current_interrupt];

    // Update priority map and vector table when updated
    if (priority_map_update) begin
        priority_map = priority_map_value;
    end
    if (vector_table_update) begin
        vector_table = vector_table_value;
    end
    if (interrupt_mask_update) begin
        interrupt_mask = interrupt_mask_value;
    end

endmodule