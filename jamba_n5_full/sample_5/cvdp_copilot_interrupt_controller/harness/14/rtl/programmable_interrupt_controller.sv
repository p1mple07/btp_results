module interrupt_controller #(
    parameter NUM_INTERRUPTS = 4, 
    parameter ADDR_WIDTH = 8)
(
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

    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] mask;
    logic [NUM_INTERRUPTS-1:0] priority;
    logic [NUM_INTERRUPTS-1:0] selected_index;

    initial begin
        rst_n ?
            ($display("RST"));
        else
            pending_interrupts <= 0;
            mask <= 0;
            priority <= 0;
            selected_index <= 0;
        end
    end

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            pending_interrupts <= 0;
            interrupt_service <= 0;
            cpu_interrupt <= 0;
            cpu_ack <= 0;
            interrupt_vector <= 0;
            priority_map_value <= {{{NUM_INTERRUPTS*NUM_INTERRUPTS, 1}}};
            vector_table_value <= {{{ADDR_WIDTH*NUM_INTERRUPTS, 1}}};
            interrupt_mask_value <= 0;
            interrupt_mask <= 0;
            selected_index <= 0;
        } else begin
            // Evaluate pending interrupts
            pending_interrupts = interrupt_requests;
            mask = interrupt_mask_value;
            selected_index = -1;
            for (int i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                if (pending_interrupts[i] && ~mask[i]) begin
                    if (selected_index == -1 || priority[i] < priority[selected_index]) begin
                        selected_index = i;
                    end
                end
            end

            if (selected_index != -1) begin
                interrupt_service <= (interrupt_service == 1'b1) ? 0 : 1'b1;
                cpu_interrupt <= 1'b1;
                interrupt_vector <= vector_table[selected_index];
                cpu_ack <= 1'b0;
            end else begin
                interrupt_service <= 0;
                cpu_interrupt <= 0;
                cpu_ack <= 0;
            end
        end
    end

endmodule
