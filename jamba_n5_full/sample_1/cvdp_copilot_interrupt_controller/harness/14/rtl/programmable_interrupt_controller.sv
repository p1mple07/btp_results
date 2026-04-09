module interrupt_controller (
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

    // Internal state variables
    logic [NUM_INTERRUPTS-1:0] pending_priority;
    logic pending_mask;
    logic pending_selected;

    // Always block for clocked operations
    always @(posedge clk) begin
        #5;
        if (!rst_n) begin
            // Reset initialization
            priority_mask <= 0;
            pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
            interrupt_mask <= 0;
            interrupt_service <= 0;
            cpu_interrupt => 0;
            cpu_ack => 0;
            interrupt_vector <= 0;
            priority_map_value <= priority_map_value;
            vector_table_value <= vector_table_value;
            interrupt_mask_value <= interrupt_mask_value;
            interrupt_mask_update <= interrupt_mask_update;
        end else begin
            // Evaluate pending interrupts
            for (integer i = 0; i < NUM_INTERRUPTS; i++) begin
                if (interrupt_mask[i] == 1'b0 && interrupt_requests[i] == 1) begin
                    if (pending_mask[i] == 1'b0) begin
                        // This interrupt is not masked
                        if (pending_priority[i] == 0) begin
                            // Highest priority found
                            interrupt_service <= i;
                            interrupt_vector <= vector_table[i];
                            interrupt_idx <= i;
                            priority_map_value <= priority_map_value;
                            pending_mask[i] = 1'b1;
                            pending_priority[i] = pending_priority[i]; // redundant
                            pending_is_selected <= 1'b1;
                        end
                    end
                end
            end
        end
    end

    assign interrupt_service = interrupt_idx;
    assign interrupt_vector = interrupt_vector;
    assign cpu_interrupt = pending_selected;
    assign cpu_ack = ~cpu_interrupt;

endmodule
