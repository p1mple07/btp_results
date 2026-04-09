module interrupt_controller (
    input  clk,
    input  rst_n,
    input  [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic cpu_interrupt,
    output logic [ADDR_WIDTH-1:0] interrupt_vector,
    input  [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic priority_map_update,
    input  logic [ADDR_WIDTH-1:0] vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic interrupt_mask_update
);

    logic [NUM_INTERRUPTS-1:0] priority_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] best_interrupt;
    logic best_priority;
    logic best_vector;

    initial begin
        priority_mask   = 0;
        pending_interrupts = 0;
        best_interrupt   = -1;
        best_priority    = INF;
        best_vector      = 0;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            interrupt_service   <= 0;
            interrupt_vector     <= 0;
            cpu_interrupt        <= 0;
            priority_mask        = 0;
            priority_map_value    <= { {1'b0} };
            vector_table_value    <= { {1'b0} };
            vector_table_update   <= 0;
            interrupt_mask_value   <= { {1'b0} };
            interrupt_mask_update  <= 0;
            best_interrupt         = -1;
        end else begin
            for (integer i = 0; i < NUM_INTERRUPTS; i++) begin
                if (interrupt_requests[i] && !interrupt_mask[i]) begin
                    if (best_interrupt == -1) begin
                        best_interrupt = i;
                        best_priority    = priority_map[i];
                        best_vector      = vector_table[i * ADDR_WIDTH : ADDR_WIDTH];
                    end else begin
                        if (priority_map[i] < best_priority) begin
                            best_interrupt = i;
                            best_priority    = priority_map[i];
                            best_vector      = vector_table[i * ADDR_WIDTH : ADDR_WIDTH];
                        end
                    end
                end
            end

            if (best_interrupt != -1) begin
                interrupt_service[0]   = 1;
                interrupt_vector[0]     = best_vector[0];
                interrupt_idx           = best_interrupt;
                cpu_interrupt            = 1;
                interrupt_service        <= 0;
                interrupt_service        <= 0;
            end else begin
                interrupt_service        <= 0;
            end
        end
    end

endmodule
