module interrupt_controller 
#(
    parameter NUM_ INTERRUPTS = 4, 
    parameter ADDR_WIDTH = 8)
(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_ INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_ INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
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

    // Priority Evaluation
    assign priority_mask = ~interrupt_mask_value;
    assign pending_interrupts = (interrupt_requests & ~interrupt_service & ~interrupt_mask) & priority_mask;
    assign interrupt_service = (priority_mask == NUM_INTERRUPTS'b1)? 1'bz : priority_map_value[priority_map_value - 1];

    // Vector Table Setup
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            interrupt_vector <= 'h0;
        end else if (vector_table_update) begin
            interrupt_vector <= vector_table_value[interrupt_service];
        end
    end

    // Reset Logic
    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            pending_interrupts <= 'h0;
        end
    end

    // CPU Acknowledgement
    always @(posedge cpu_interrupt) begin
        interrupt_service <= 'h0;
        interrupt_mask <= 'h0;
    end

    // Dynamic Updates
    always @(posedge priority_map_update or posedge vector_table_update or posedge interrupt_mask_update) begin
        if (priority_map_update) begin
            priority_mask <= ~priority_map_value;
        end
        if (vector_table_update) begin
            interrupt_vector <= vector_table_value[interrupt_service];
        end
        if (interrupt_mask_update) begin
            interrupt_mask <= interrupt_mask_value;
        end
    end

    // CPU Interaction
    assign cpu_interrupt = (|pending_interrupts) && ~(|interrupt_service);

endmodule