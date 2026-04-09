// SystemVerilog RTL for a Priority-Based Interrupt Controller with APB Interface

module interrupt_controller_apb #(
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
    output  logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    
    // APB Interface Signals
    input  logic                      pclk,
    input  logic                      presetn,
    input  logic                      psel,
    input  logic                      penable,
    input  logic                      pwrite,
    input  logic [ADDR_WIDTH-1:0]     paddr,
    input  logic [31:0]               pwdata,
    output logic [31:0]               prdata,
    output logic                      pready
);

    logic [NUM_INTERRUPTS-1:0] interrupt_mask;
    logic servicing;
    logic [NUM_INTERRUPTS-1:0] pending_interrupts;

    // Priority Map Register
    reg [NUM_INTERRUPTS-1:0] priority_map [NUM_INTERRUPTS-1:0];
    // Initialize priority_map with sequential priorities
    initial begin
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            priority_map[i] = i;
        end
    end

    // Interrupt Mask Register
    reg [NUM_INTERRUPTS-1:0] interrupt_mask;
    // Initialize interrupt_mask to all 1's (all interrupts enabled)
    initial begin
        interrupt_mask = {NUM_INTERRUPTS{1'b1}};
    end

    // Vector Table Register
    reg [ADDR_WIDTH-1:0] vector_table [NUM_INTERRUPTS-1:0];
    // Initialize vector_table with sequential addresses
    initial begin
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            vector_table[i] = i << (ADDR_WIDTH-1);
        end
    end

    // Interrupt Request Handling
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            interrupt_mask <= {NUM_INTERRUPTS{1'b1}};
            pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
            interrupt_idx <= 0;
            interrupt_service <= 0;
        end else begin
            // Interrupt arbitration logic
            interrupt_idx = 0;
            interrupt_service = 0;
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (interrupt_mask[i] && interrupt_requests[i]) begin
                    interrupt_idx = i;
                    interrupt_service = 1;
                    break;
                end
            end
        end
    end

    // APB Interface Logic
    always @(posedge pclk or posedge presetn or posedge rst_n) begin
        if (rst_n) begin
            // Reset APB registers
            prdata <= 0;
            pready <= 0;
        end else if (presetn) begin
            // Reconfigure APB registers
            // (e.g., reconfigure priority_map, interrupt_mask, vector_table)
        end else begin
            // APB Interface Logic
            case (paddr)
                // Define APB register mappings and logic for read/write operations
            endcase
        end
    end

    // Interrupt Service Handling
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            servicing <= 0;
        end else begin
            // Interrupt service completion logic
            if (interrupt_service && cpu_ack) begin
                servicing <= 1;
                interrupt_service <= 0;
                // Clear interrupt in pending_interrupts register
                pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
                interrupt_idx <= 0;
            end
        end
    end

    // Outputs
    assign interrupt_vector = vector_table[interrupt_idx];
    assign pready = servicing || interrupt_service;

endmodule
