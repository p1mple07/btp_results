module interrupt_controller 
#(
    parameter NUM_ INTERRUPTS = 4, 
    parameter ADDR_WIDTH = 8)
(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    input  logic [NUM_ INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

    logic [NUM_INTERRUPTS-1:0] priority_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] interrupt_mask;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
            //...
        end else begin
            // Update priority map
            if (priority_map_update) begin
                for (int i=0; i<NUM_INTERRUPTS; i++) begin
                    priority_mask[i] <= ~priority_map_value[i];
                end
            end

            // Update vector table
            if (vector_table_update) begin
                for (int i=0; i<NUM_INTERRUPTS; i++) begin
                    vector_table[i] <= vector_table_value[i];
                end
            end

            // Update interrupt mask
            if (interrupt_mask_update) begin
                interrupt_mask <= interrupt_mask_value;
            end

            // Evaluate pending interrupts and select the highest priority interrupt that is not masked
            for (int i=0; i<NUM_ INTERRUPTS; i++) begin
                pending_interrupts[i] <= priority_mask[i] & interrupt_requests[i] & ~interrupt_service[i];
            end

            // Handle pending interrupts
            for (int i=0; i<NUM_ INTERRUPTS; i++) begin
                if (pending_interrupts[i]) begin
                    cpu_interrupt <= 1;
                    interrupt_service[i] <= 1;
                    interrupt_vector[i*4+3:i*4] <= vector_table[i];
                end
            end

            // Clear interrupt signals and wait for the next interrupt
            for (int i=0; i<NUM_ INTERRUPTS; i++) begin
                if (interrupt_service[i]) begin
                    interrupt_service[i] <= 0;
                    if (cpu_ack) begin
                        cpu_interrupt <= 0;
                    end
                end
            end
        end
    end

endmodule