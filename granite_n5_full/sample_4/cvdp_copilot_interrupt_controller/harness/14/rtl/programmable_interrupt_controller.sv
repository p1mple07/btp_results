module programmable_interrupt_controller 
(
    input  logic clk,
    input  logic rst_n,
    input  logic [NUM_ INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_ INTERRUPTS-1:0] interrupt_service,
    output logic cpu_interrupt,
    input  logic cpu_ack,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    input  logic [NUM_ INTERRUPTS-1:0] priority_map_value [NUM_ INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_ INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_ INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

    logic [NUM_ INTERRUPTS-1:0] priority_mask;
    logic [NUM_ INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_ INTERRUPTS-1:0] interrupt_mask;

    assign interrupt_service = ~pending_interrupts & interrupt_mask;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            pending_interrupts <= '0;
            interrupt_mask <= '1;
            priority_mask <= '0;
        end else begin
            if (priority_map_update) begin
                for (genvar i = 0; i < NUM_INTERRUPTS; i++) begin
                    if (~priority_mask[i]) begin
                        priority_mask[i] <= priority_map_value[i];
                    end
                end
            end

            if (vector_table_update) begin
                for (genvar i = 0; i < NUM_INTERRUPTS; i++) begin
                    if (~priority_mask[i]) begin
                        interrupt_vector[i*ADDR_WIDTH +: ADDR_WIDTH] <= vector_table_value[i];
                    end
                end
            end

            if (interrupt_mask_update) begin
                interrupt_mask <= interrupt_mask_value;
            end

            for (genvar i = 0; i < NUM_INTERRUPTS; i++) begin
                pending_interrupts[i] <= priority_mask[i] & interrupt_requests[i] & ~interrupt_service[i];
            end
        end
    end

    always_comb begin
        if (cpu_interrupt &&!cpu_ack) begin
            cpu_interrupt <= 0;
            interrupt_service <= {NUM_INTERRUPTS{1'b0}};
        end
    end

endmodule