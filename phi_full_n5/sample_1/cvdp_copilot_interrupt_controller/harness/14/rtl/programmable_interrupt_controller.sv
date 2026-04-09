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

    // Initialize registers and internal state on reset
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            interrupt_service <= {NUM_INTERRUPTS{1'b0}};
            interrupt_vector <= {NUM_INTERRUPTS{1'b0}};
            priority_mask <= {NUM_INTERRUPTS{1'b1}};
            interrupt_mask <= {NUM_INTERRUPTS{1'b0}};
            pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
        end else begin
            if (priority_map_update) begin
                priority_mask <= priority_map_value;
            end
            if (vector_table_update) begin
                interrupt_vector <= vector_table_value;
            end
            if (interrupt_mask_update) begin
                interrupt_mask <= interrupt_mask_value;
            end
        end
    end

    // Evaluate and handle interrupts
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
        end else begin
            // Evaluate interrupts
            pending_interrupts <= {interrupt_requests{NUM_INTERRUPTS-1}} & (~priority_mask);

            // Find highest priority interrupt
            interrupt_service <= {interrupt_requests{NUM_INTERRUPTS-1}} & (priority_mask & ~interrupt_mask) & (~pending_interrupts);

            // If interrupt is pending and CPU is ready
            if (~interrupt_service[0] & cpu_interrupt & ~cpu_ack) begin
                interrupt_vector <= interrupt_vector_map[interrupt_service];
                cpu_interrupt <= 0;
                interrupt_ack_flag <= 1;
            end
        end
    end

    // Interrupt vector map
    localparam [ADDR_WIDTH-1:0] interrupt_vector_map [NUM_INTERRUPTS-1:0];
    integer i;
    initial begin
        for (i=0; i<NUM_INTERRUPTS; i=i+1) begin
            interrupt_vector_map[i] = i*4;
        end
    end

    // Interrupt acknowledgment
    logic interrupt_ack_flag;
    always_ff @(posedge clk) begin
        if (cpu_ack & interrupt_ack_flag) begin
            interrupt_ack_flag <= 0;
            interrupt_service <= {NUM_INTERRUPTS{1'b0}};
        end
    end

endmodule
