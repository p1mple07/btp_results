module interrupt_controller #(
    parameter NUM_INTERRUPTS = 4,
    parameter ADDR_WIDTH = 8
)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
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

    // Reset logic
    always_comb begin
        if (~rst_n) begin
            priority_mask <= {NUM_INTERRUPTS{1'b0}};
            vector_table <= {NUM_INTERRUPTS{32'd0}};
            interrupt_mask <= '{NUM_INTERRUPTS{0}}';
            interrupt_service <= 4'b0;
            cpu_interrupt <= 0;
            cpu_ack <= 0;
            interrupt_vector[NUM_INTERRUPTS-1:] <= 4'b0;
        end else begin
            // Process interrupts on clock
            priority_mask = priority_map;
            interrupt_mask = interrupt_mask_value;
            interrupt_requests = interrupt_requests;

            localvar best_index = NUM_INTERRUPTS;
            localvar int best_priority = 16'dFFFFFFFF;
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (interrupt_requests[i] && !interrupt_mask_value[i]) begin
                    int priority = priority_map[i];
                    if (priority < best_priority) begin
                        best_priority = priority;
                        best_index = i;
                    end
                end
            end
            if (best_index != NUM_INTERRUPTS) begin
                interrupt_service[best_index] = 1;
                interrupt_vector[best_index*ADDR_WIDTH : ADDR_WIDTH] = {1'b0};
                cpu_interrupt <= 1;
            end else
                interrupt_service[best_index] = 0;
        end
    end

    // Dynamic updates
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all
            priority_mask <= {NUM_INTERRUPTS{1'b0}};
            vector_table <= {NUM_INTERRUPTS{32'd0}};
            interrupt_mask <= '{NUM_INTERRUPTS{0}}';
            interrupt_service <= 4'b0;
            cpu_interrupt <= 0;
            cpu_ack <= 0;
            interrupt_vector[NUM_INTERRUPTS-1:] <= 4'b0;
        end else begin
            // Update priority map
            if (priority_map_update) begin
                priority_mask <= priority_map_value;
            end
            // Update vector table
            if (vector_table_update) begin
                vector_table <= vector_table_value;
            end
            // Update interrupt mask
            if (interrupt_mask_update) begin
                interrupt_mask <= interrupt_mask_value;
            end
        end
    end

endmodule
