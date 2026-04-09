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

    // Initialize state variables
    logic [NUM_INTERRUPTS-1:0] priority_mask = (1 << NUM_INTERRUPTS) - 1;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts = 0;
    logic [NUM_INTERRUPTS-1:0] interrupt_mask = 0;

    // Evaluate highest priority non-masked interrupt
    logic select Interrupt;
    case (priority_mask & pending_interrupts)
        default: Interrupt = 0;
        endcase
    endcase

    // Service the selected interrupt
    if (Interrupt != 0) begin
        // Notify CPU to service interrupt
        cpu_interrupt = 1;
        
        // Wait for CPU acknowledgment
        cpu_ack = 1;
        
        // Clear service signals and update state
        interrupt_service = 0;
        pending_interrupts = 0;
        if (interrupt_mask_value) begin
            interrupt_mask = interrupt_mask_value;
        end
    end else begin
        // Timeout, wait for next interrupt
        pending_interrupts = 0;
    end

    // Update priority map, vector table, and mask if applicable
    if (priority_map_update) begin
        priority_mask = priority_map_value;
    end
    if (vector_table_update) begin
        vector_table_value = vector_table_value;
    end
    if (interrupt_mask_update) begin
        interrupt_mask = interrupt_mask_value;
    end

endmodule