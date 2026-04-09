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
    output logic [CLOG2_NUM_INTERRUPTS-1:0] interrupt_idx,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    input  logic [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

    // Calculate logarithm base 2 of NUM_INTERRUPTS for index width
    localparam int CLOG2_NUM_INTERRUPTS = $clog2(NUM_INTERRUPTS);

    // Internal registers for dynamic configuration and state
    logic [NUM_INTERRUPTS-1:0] internal_priority_map [NUM_INTERRUPTS-1:0];
    logic [ADDR_WIDTH-1:0]     internal_vector_table [NUM_INTERRUPTS-1:0];
    logic [NUM_INTERRUPTS-1:0] internal_interrupt_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [CLOG2_NUM_INTERRUPTS-1:0] current_interrupt;

    // Combinational block: Evaluate pending interrupts (that are not masked)
    // and select the one with the lowest priority value (i.e. highest priority)
    wire [CLOG2_NUM_INTERRUPTS-1:0] selected_interrupt_comb;
    always_comb begin
        selected_interrupt_comb = 0;
        // Use a local variable to track the best (lowest) priority seen so far.
        logic [NUM_INTERRUPTS-1:0] best_priority;
        best_priority = {NUM_INTERRUPTS{1'b1}}; // initialize to maximum value
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (pending_interrupts[i] && !internal_interrupt_mask[i]) begin
                if (internal_priority_map[i] < best_priority) begin
                    best_priority = internal_priority_map[i];
                    selected_interrupt_comb = i;
                end
            end
        end
    end

    // Output assignments based on the selected interrupt
    assign interrupt_service   = (1 << selected_interrupt_comb);
    assign cpu_interrupt       = (selected_interrupt_comb != 0);
    assign interrupt_idx       = selected_interrupt_comb;
    assign interrupt_vector    = (selected_interrupt_comb != 0) ? internal_vector_table[selected_interrupt_comb] : '0;

    // Sequential logic: Register updates, pending interrupt accumulation, and CPU acknowledgment
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset: initialize all registers to default values
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                // Default priority: sequential values (0, 1, 2, …)
                internal_priority_map[i] <= i;
                // Default vector table: assign vectors as multiples of 4
                internal_vector_table[i] <= i * 4;
                // Default mask: all interrupts unmasked
                internal_interrupt_mask[i] <= 1'b0;
            end
            pending_interrupts <= '0;
            current_interrupt  <= '0;
        end
        else begin
            // Dynamic updates: update registers when respective update signals are asserted
            if (priority_map_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    internal_priority_map[i] <= priority_map_value[i];
                end
            end
            if (vector_table_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    internal_vector_table[i] <= vector_table_value[i];
                end
            end
            if (interrupt_mask_update) begin
                for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                    internal_interrupt_mask[i] <= interrupt_mask_value[i];
                end
            end

            // Accumulate new interrupt requests
            pending_interrupts <= pending_interrupts | interrupt_requests;

            // Update the current interrupt based on the combinational selection logic
            current_interrupt <= selected_interrupt_comb;

            // When the CPU acknowledges the serviced interrupt, clear it from pending interrupts
            if (cpu_ack) begin
                pending_interrupts <= pending_interrupts & ~(1 << current_interrupt);
            end
        end
    end

endmodule