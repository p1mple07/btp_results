module interrupt_controller 
#(
    parameter NUM_ INTERRUPTS = 4, 
    parameter ADDR_WIDTH = 8)
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
    
    // Define local parameters
    localparam PRIORITY_MAP_DEFAULT = {NUM_INTERRUPTS{1'b0}};
    localparam VECTOR_TABLE_DEFAULT = {NUM_INTERRUPTS{ADDR_WIDTH'd0}};
    localparam INTERFACE_VECTOR_DEFAULT = ADDR_WIDTH'h0;
    localparam INTERFACE_INDEX_DEFAULT = ADDR_WIDTH'h0;

    // Declare internal signals and registers
    logic [NUM_INTERRUPTS-1:0] priority_mask;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;
    logic [NUM_INTERRUPTS-1:0] interrupt_mask;

    // Priority mask initialization
    assign priority_mask = {NUM_INTERRUPTS{1'b1}};

    // Initialize pending interrupts to all ones
    assign pending_interrupts = ~interrupt_requests & interrupt_mask;

    // Generate interrupt_service signal
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            interrupt_service <= '0;
        end else begin
            if (pending_interrupts[0]) begin
                interrupt_service <= priority_mask;
            end else begin
                interrupt_service <= '0;
            end
        end
    end

    // Generate interrupt_vector signal
    always_comb begin
        if (interrupt_service[0]) begin
            interrupt_vector <= VECTOR_TABLE_DEFAULT;
        end else begin
            interrupt_vector <= '0;
        end
    end

    // Update priority_mask based on priority_map_update signal
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            priority_mask <= PRIORITY_MAP_DEFAULT;
        end else begin
            if (priority_map_update) begin
                priority_mask <= priority_map_value;
            end
        end
    end

    // Update interrupt_mask based on interrupt_mask_update signal
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            interrupt_mask <= ~interrupt_mask_value;
        end else begin
            if (interrupt_mask_update) begin
                interrupt_mask <= interrupt_mask_value;
            end
        end
    end

    // CPU acknowledgment handling
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cpu_interrupt <= 1'b0;
        end else begin
            if (cpu_interrupt) begin
                cpu_interrupt <= 1'b0;
            end
        end
    end

endmodule