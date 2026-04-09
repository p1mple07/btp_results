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

    // Initialize registers
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            interrupt_service <= 0;
            interrupt_vector <= {1'b0, {ADDR_WIDTH{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
            priority_mask <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
            interrupt_mask <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
            pending_interrupts <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
        end else begin
            interrupt_service <= 0;
            interrupt_vector <= {1'b0, {ADDR_WIDTH{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
            priority_mask <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
            interrupt_mask <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
            pending_interrupts <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
        end
    end

    // Interrupt handling logic
    always @(posedge clk) begin
        if (!rst_n) begin
            interrupt_mask <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
        end else begin
            // Evaluate interrupts and set interrupt_service
            interrupt_service <= 0;
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (interrupt_requests[i] && !interrupt_mask[i] && !pending_interrupts[i]) begin
                    interrupt_service[i] <= 1;
                    interrupt_vector <= vector_table_value[i];
                    interrupt_mask[i] <= 1;
                    interrupt_pending(i) <= 1;
                    break;
                end
            end
        end
    end

    // Signal CPU for interrupt servicing
    always @(posedge clk) begin
        if (cpu_interrupt && !cpu_ack) begin
            interrupt_service <= 0;
            interrupt_vector <= {1'b0, {ADDR_WIDTH{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
            cpu_interrupt <= 0;
        end
    end

    // Update logic for priority map and vector table
    always @(posedge clk) begin
        if (priority_map_update || vector_table_update) begin
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (priority_map_update) begin
                    priority_mask[i] <= priority_map_value[i];
                end
                if (vector_table_update) begin
                    interrupt_vector[i] <= vector_table_value[i];
                end
            end
        end
    end

    // Update interrupt mask
    always @(posedge clk) begin
        if (interrupt_mask_update) begin
            interrupt_mask <= interrupt_mask_value;
        end
    end

    // Compute interrupt index
    logic [NUM_INTERRUPTS-1:0] interrupt_idx;
    always @(posedge clk) begin
        if (interrupt_service != 0) begin
            interrupt_idx <= (NUM_INTERRUPTS-1) - (priority_mask > interrupt_service) + interrupt_pending;
        end
    end

    // Define interrupt_pending
    always @(posedge clk) begin
        if (interrupt_service == 0) begin
            pending_interrupts <= {1'b0, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
        end else begin
            pending_interrupts <= {1'b1, {NUM_INTERRUPTS{1'b0}}} + {NUM_INTERRUPTS{1'b0}};
        end
    end

endmodule
