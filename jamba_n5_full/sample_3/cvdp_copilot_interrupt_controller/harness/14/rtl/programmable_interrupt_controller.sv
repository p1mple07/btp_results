module interrupt_controller #(
    parameter NUM_INTERRUPTS = 4,
    parameter ADDR_WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic cpu_interrupt,
    output logic [ADDR_WIDTH-1:0] interrupt_vector,
    input  logic [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic priority_map_update,
    input  logic [ADDR_WIDTH-1:0] vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic interrupt_mask_update
);

    logic [NUM_INTERRUPTS-1:0] priority_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] masked_interrupts;
    logic selected_interrupt;

    always_ff @(posedge clk) begin
        if (rst_n) begin
            priority_mask <= {[0:NUM_INTERRUPTS-1] 1'b1};
            pending_interrupts <= {[0:NUM_INTERRUPTS-1] 1'b0};
            masked_interrupts <= {[0:NUM_INTERRUPTS-1] 1'b0};
            selected_interrupt <= 0;
        end else begin
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (!interrupt_mask[i]) begin
                    if (pending_interrupts[i] == 1) begin
                        selected_interrupt = i;
                        break;
                    end
                end
            end

            if (selected_interrupt != 0) begin
                interrupt_service[selected_interrupt] <= 1;
                cpu_interrupt => 1;
                interrupt_vector[selected_interrupt * ADDR_WIDTH : ADDR_WIDTH] <= priority_map[selected_interrupt];
                for (int j = 0; j < NUM_INTERRUPTS; j++) begin
                    if (j != selected_interrupt && interrupt_service[j] == 1) begin
                        interrupt_service[j] <= 0;
                        interrupt_vector[j * ADDR_WIDTH : ADDR_WIDTH] <= 4'b0000;
                    end
                end
            end else begin
                interrupt_service <= 0;
                cpu_interrupt <= 0;
                cpu_ack <= 0;
                interrupt_vector <= 4'b0000;
            end
        end
    end

endmodule
