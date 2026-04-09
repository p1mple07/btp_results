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

    // Initialize default priority map and vector table
    logic [NUM_INTERRUPTS-1:0] priority_map = {3,2,1,0};
    logic [NUM_INTERRUPTS-1:0] vector_table = {12,8,4,0};
    logic [NUM_INTERRUPTS-1:0] interrupt_mask = 15; // All interrupts active by default

    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] busy;
    logic [NUM_INTERRUPTS-1:0] current_interrupt;

    // Always active logic
    always logic
    begin
        // Initialize on first clock cycle
        if (rst_n) begin
            pending_interrupts = 0;
            busy = 0;
            current_interrupt = 0;
        end

        // Process interrupts
        if (!busy) begin
            // Check interrupts in order of priority (lowest first)
            for (int i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                if ((pending_interrupts & (1 << i)) && (interrupt_mask[i] == 1)) begin
                    // Service this interrupt
                    interrupt_service = (1 << i);
                    cpu_interrupt = 1;
                    pending_interrupts = pending_interrupts ^ (1 << i);
                    interrupt_mask = interrupt_mask ^ (1 << i);
                    current_interrupt = i;
                    busy = 1;
                    break;
                end
            end
        end

        // Wait for CPU acknowledgment
        while (cpu_ack) begin
            // Clear service signals and reset state
            interrupt_service = 0;
            cpu_interrupt = 0;
            pending_interrupts = 0;
            interrupt_mask = 15;
            busy = 0;
            current_interrupt = 0;
        end
    end

    // Handle dynamic updates
    always logic
    begin
        // Only update if we're not busy
        if (!busy) begin
            // Update priority map
            if (priority_map_update) begin
                priority_map = priority_map_value;
            end
            // Update vector table
            if (vector_table_update) begin
                vector_table = vector_table_value;
            end
            // Update interrupt mask
            if (interrupt_mask_update) begin
                interrupt_mask = interrupt_mask_value;
            end
        end
    end
endmodule