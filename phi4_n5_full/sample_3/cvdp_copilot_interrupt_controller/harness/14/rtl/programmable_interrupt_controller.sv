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
    output logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
    input  logic [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

    // Internal registers for dynamic updates and state
    reg [NUM_INTERRUPTS-1:0] priority_map_reg [0:NUM_INTERRUPTS-1];
    reg [ADDR_WIDTH-1:0]     vector_table_reg [0:NUM_INTERRUPTS-1];
    reg [NUM_INTERRUPTS-1:0] interrupt_mask_reg;
    reg [NUM_INTERRUPTS-1:0] pending_interrupts;
    reg [$clog2(NUM_INTERRUPTS)-1:0] current_interrupt_idx;
    reg cpu_interrupt_reg;

    // Next interrupt to be serviced (combinational selection)
    reg [$clog2(NUM_INTERRUPTS)-1:0] next_interrupt;

    // Combinational block: Select the highest priority pending interrupt that is not masked.
    // Lower numeric value in priority_map_reg indicates higher priority.
    always_comb begin
        next_interrupt = 0; // Default: no interrupt selected.
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (pending_interrupts[i] && ~interrupt_mask_reg[i]) begin
                // If no current candidate or found a lower priority value, select this interrupt.
                if (next_interrupt == 0 || priority_map_reg[i] < priority_map_reg[next_interrupt])
                    next_interrupt = i;
            end
        end
    end

    // Sequential logic: Update internal state, registers, and select the interrupt to service.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to default values.
            pending_interrupts       <= '0;
            current_interrupt_idx    <= 0;
            cpu_interrupt_reg        <= 0;
            // Initialize priority map: sequential priorities (lower number = higher priority)
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                priority_map_reg[i] <= i;
            end
            // Initialize vector table: assign vectors as multiples of 4.
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                vector_table_reg[i] <= i * 4;
            end
            // Default interrupt mask: 0 (no interrupts masked).
            interrupt_mask_reg <= '0;
        end
        else begin
            // Dynamic update of registers if update signals are asserted.
            if (priority_map_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    priority_map_reg[i] <= priority_map_value[i];
                end
            end
            if (vector_table_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    vector_table_reg[i] <= vector_table_value[i];
                end
            end
            if (interrupt_mask_update) begin
                interrupt_mask_reg <= interrupt_mask_value;
            end

            // Update pending interrupts: OR in new requests.
            pending_interrupts <= pending_interrupts | interrupt_requests;

            // If the CPU acknowledges servicing the current interrupt, clear it.
            if (cpu_ack && (current_interrupt_idx != 0)) begin
                pending_interrupts <= pending_interrupts & ~(1 << current_interrupt_idx);
                current_interrupt_idx <= 0;
            end
            // If no interrupt is currently being serviced, select the next pending interrupt.
            else if (current_interrupt_idx == 0) begin
                current_interrupt_idx <= next_interrupt;
            end

            // Assert cpu_interrupt if an interrupt is being serviced.
            cpu_interrupt_reg <= (current_interrupt_idx != 0);
        end
    end

    // Output assignments.
    assign cpu_interrupt      = cpu_interrupt_reg;
    assign interrupt_service  = (current_interrupt_idx != 0) ? (1 << current_interrupt_idx) : '0;
    assign interrupt_vector   = (current_interrupt_idx != 0) ? vector_table_reg[current_interrupt_idx] : '0;
    assign interrupt_idx      = current_interrupt_idx;

endmodule