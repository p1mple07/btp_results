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

    logic [NUM_INTERRUPTS-1:0] interrupt_idx;

    // Initialize registers
    always_ff @(posedge clk) begin
        if (rst_n) begin
            interrupt_service <= 0;
            interrupt_idx <= 0;
            interrupt_vector <= {0{ADDR_WIDTH{1'b0}}} ;
            priority_mask <= {0{NUM_INTERRUPTS{1'b0}}} ;
            interrupt_mask <= {0{NUM_INTERRUPTS{1'b0}}} ;
        end else begin
            interrupt_service <= 0;
            interrupt_idx <= 0;
            interrupt_vector <= {0{ADDR_WIDTH{1'b0}}} ;
            priority_mask <= {0{NUM_INTERRUPTS{1'b0}}} ;
            interrupt_mask <= {0{NUM_INTERRUPTS{1'b0}}} ;
        end
    end

    // Interrupt priority evaluation
    always_comb begin
        priority_mask = 1'b1;
        interrupt_idx = 0;
        interrupt_vector = {0{ADDR_WIDTH{1'b0}}} ;

        // Check interrupts for masking and priority
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (!interrupt_mask[i] && priority_map_value[i] != 0) begin
                interrupt_idx = i;
                interrupt_vector = vector_table_value[i];
                interrupt_service = 1;
                interrupt_mask = 1;
                priority_mask[i] = 1'b1;
                break;
            end
        end
    end

    // Update priority map and mask
    always_ff @(posedge clk) begin
        if (priority_map_update) begin
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                priority_map_value[i] <= priority_map_value[i];
            end
        end
        if (interrupt_mask_update) begin
            interrupt_mask <= interrupt_mask;
        end
    end

    // Update vector table
    always_ff @(posedge clk) begin
        if (vector_table_update) begin
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                vector_table_value[i] <= vector_table_value[i];
            end
        end
    end

    // CPU interaction
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            cpu_interrupt <= 0;
        end else begin
            if (interrupt_idx != 0) begin
                interrupt_service <= 1;
                interrupt_idx <= interrupt_idx;
                interrupt_vector <= interrupt_vector;
                cpu_interrupt <= 1;
            end
        end
    end

    // Acknowledge CPU
    always_ff @(posedge clk) begin
        if (cpu_ack) begin
            interrupt_service <= 0;
            interrupt_idx <= 0;
            interrupt_vector <= {0{ADDR_WIDTH{1'b0}}} ;
            interrupt_mask <= {0{NUM_INTERRUPTS{1'b0}}} ;
        end
    end

endmodule
