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

    // Initialize registers on reset
    logic [NUM_INTERRUPTS-1:0] priority_map [NUM_INTERRUPTS-1:0];
    logic [NUM_INTERRUPTS-1:0] vector_table [ADDR_WIDTH-1:0];
    logic [NUM_INTERRUPTS-1:0] interrupt_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic current_interrupt;

    // Initialize to default values on reset
    initial begin
        priority_map = { replicate({i: 1}, NUM_INTERRUPTS) };
        vector_table = { replicate({i*4}, ADDR_WIDTH) };
        interrupt_mask = 0;
        pending_interrupts = 0;
    end

    // Always update priority map
    always priority_map_value when priority_map_update;
    assign priority_map = priority_map_value;

    // Always update vector table
    always vector_table_value when vector_table_update;
    assign vector_table = vector_table_value;

    // Always update interrupt mask
    always interrupt_mask_value when interrupt_mask_update;
    assign interrupt_mask = interrupt_mask_value;

    // Main processing logic
    process (clk, cpu_ack) begin
        // Check if any interrupts are pending and not masked
        pending_interrupts = 0;
        current_interrupt = 0;
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (priority_mask[i] & pending_interrupts & !interrupt_mask[i]) begin
                current_interrupt = i;
                break;
            end
        end

        // If an interrupt is being serviced
        if (current_interrupt != 0) begin
            // Set the interrupt vector
            interrupt_vector = vector_table[current_interrupt];
            
            // Notify the CPU
            cpu_interrupt = 1;
            
            // Wait for CPU acknowledgment
            while (1) begin
                if (cpu_ack) begin
                    cpu_interrupt = 0;
                    break;
                end
                // Prevent multiple service completions in one cycle
                else begin
                    cpu_interrupt = 0;
                end
            end
        else begin
            // Clear any pending service
            pending_interrupts = 0;
        end
    end

endmodule