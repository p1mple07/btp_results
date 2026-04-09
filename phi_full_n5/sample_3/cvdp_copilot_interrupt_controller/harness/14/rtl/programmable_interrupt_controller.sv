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
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    input  logic [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

    logic [NUM_INTERRUPTS-1:0] priority_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] interrupt_mask;
    logic [NUM_INTERRUPTS-1:0] interrupt_idx;

    // Initialize registers and internal state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            priority_mask <= (NUM_INTERRUPTS - 1) * {1, 1'b0};
            interrupt_mask <= (NUM_INTERRUPTS - 1) * {1, 1'b1};
            interrupt_idx <= (NUM_INTERRUPTS - 1) * {1, 1'b0};
            pending_interrupts <= (NUM_INTERRUPTS - 1) * {1, 1'b0};
        end else begin
            if (priority_map_update) begin
                priority_mask <= priority_map_value;
            end
            if (vector_table_update) begin
                interrupt_vector <= vector_table_value;
            end
            if (interrupt_mask_update) begin
                interrupt_mask <= interrupt_mask_value;
            end
        end
    end

    // Evaluate interrupts and select highest priority interrupt
    always_comb begin
        interrupt_mask <= interrupt_mask_value;
        pending_interrupts <= interrupt_requests & ~interrupt_mask;
        interrupt_idx <= find_highest_priority_interrupt(priority_mask, pending_interrupts);
    end

    // Servicing logic
    always_ff begin
        if (cpu_interrupt & ~interrupt_service) begin
            interrupt_service <= interrupt_requests;
            interrupt_vector <= interrupt_vector_map(interrupt_idx);
            cpu_interrupt <= 0;
        end
    end

    // Function to find the highest priority interrupt
    function [NUM_INTERRUPTS-1:0] find_highest_priority_interrupt(
        logic [NUM_INTERRUPTS-1:0] priority_mask,
        logic [NUM_INTERRUPTS-1:0] pending_interrupts
    );
        // Find the index of the highest priority interrupt
        int max_priority = 0;
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (!priority_mask[i] && pending_interrupts[i]) begin
                max_priority = i;
                break;
            end
        end
        find_highest_priority_interrupt = max_priority;
    end

    // Function to map interrupt index to vector
    function logic [ADDR_WIDTH-1:0] interrupt_vector_map(
        [NUM_INTERRUPTS-1:0] interrupt_idx
    );
        interrupt_vector_map = vector_table_value[interrupt_idx];
    end

endmodule
