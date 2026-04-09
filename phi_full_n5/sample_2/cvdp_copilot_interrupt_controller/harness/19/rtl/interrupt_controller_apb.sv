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
    output logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
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

    // Interrupt Mask Register
    reg [NUM_INTERRUPTS-1:0] interrupt_mask [NUM_INTERRUPTS-1:0];

    // Vector Table Register
    reg [ADDR_WIDTH-1:0] vector_table [NUM_INTERRUPTS-1:0];

    // Initialize registers on reset
    initial begin
        if (rst_n) begin
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                priority_map[i] = i; // Sequential priority values
                interrupt_mask[i] = 1; // Enable all interrupts
            end
            pending_interrupts = 0;
            interrupt_idx = 0;
        end
    end

    // Interrupt Arbitration Logic
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            interrupt_service <= 0;
            cpu_interrupt <= 0;
            servicing <= 0;
        end else begin
            interrupt_service <= interrupt_service;
            cpu_interrupt <= servicing && interrupt_ack;
            servicing <= (pending_interrupts[interrupt_idx] && ~interrupt_mask[interrupt_idx]);
        end
    end

    // Interrupt Masking Logic
    always @(posedge clk) begin
        interrupt_mask <= (psel & penable & pwrite & (paddr != priority_map'[interrupt_idx]));
    end

    // Interrupt Vector Table Logic
    always @(posedge clk) begin
        vector_table <= (psel & penable & pwrite & (paddr != interrupt_idx));
    end

    // APB Interface Logic
    always @(posedge pclk) begin
        if (presetn) begin
            interrupt_mask <= 0; // Disable all interrupts on reset
            priority_map <= {NUM_INTERRUPTS{1'b0}}; // Reset to sequential priorities
        end

        if (penable) begin
            prdata <= pwdata; // Write data on APB write signal
            pready <= 1; // Assert ready signal
        end else begin
            prdata <= 0; // Clear data on APB read signal
            pready <= 0; // De-assert ready signal
        end
    end

endmodule
