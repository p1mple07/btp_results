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
    logic [NUM_INTERRUPTS-1:0] selected_interrupt;

    // Initialize registers during reset
    always @ (posedge clk or posedge rst_n) begin
        if (rst_n) begin
            interrupt_service <= 0;
            interrupt_vector <= 0;
            interrupt_mask <= 0;
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                priority_mask[i] = i;
                interrupt_mask[i] = 1;
                pending_interrupts[i] = interrupt_requests[i];
            end
        end else begin
            if (priority_map_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    priority_mask[i] = priority_map_value[i];
                end
            end
            if (vector_table_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    interrupt_vector[i] = vector_table_value[i];
                end
            end
            if (interrupt_mask_update) begin
                interrupt_mask = interrupt_mask_value;
            end
        end
    end

    // Interrupt evaluation and servicing logic
    always @ (posedge clk) begin
        if (!rst_n) begin
            selected_interrupt <= 0;
        end else begin
            // Evaluate pending interrupts and select the highest priority one that is not masked
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (!interrupt_mask[i] && pending_interrupts[i]) begin
                    if (priority_mask[i] < selected_interrupt || selected_interrupt == 0) begin
                        selected_interrupt <= priority_mask[i];
                    end
                end
            end

            // Set interrupt service and interrupt vector if a priority interrupt is selected
            if (selected_interrupt != 0) begin
                interrupt_service <= selected_interrupt;
                interrupt_vector <= interrupt_vector[selected_interrupt];
                cpu_interrupt <= 1;
                interrupt_mask <= interrupt_mask & ~(1 << selected_interrupt);
                pending_interrupts <= 0;
            end
        end
    end

    // Acknowledge interrupt service completion
    always @ (posedge cpu_ack) begin
        interrupt_service <= 0;
        interrupt_vector <= 0;
        interrupt_mask <= 0;
    end

endmodule
