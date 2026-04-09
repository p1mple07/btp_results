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

    // Interrupt Arbitration Logic
    always @ (posedge clk or posedge rst_n) begin
        if (rst_n) begin
            interrupt_mask <= {NUM_INTERRUPTS{1'b0}};
            servicing <= 0;
            pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
        end else begin
            interrupt_mask <= (pwrite && penable) ? interrupt_mask : {NUM_INTERRUPTS{1'b0}};
            servicing <= (interrupt_idx == interrupt_service) & (cpu_ack);
            pending_interrupts <= interrupt_requests & ~interrupt_mask;
        end
    end

    // APB Interface Logic
    assign interrupt_vector = paddr;

    // Interrupt Vector Table Read/Write
    always @ (posedge pclk) begin
        if (pwrite && penable) begin
            prdata <= pwdata;
        end else if (~pwrite && penable) begin
            pwdata <= prdata;
        end
        pready <= (pwrite && penable) | (~pwrite && penable);
    end

    // Interrupt Masking Logic
    always @ (*) begin
        interrupt_mask <= (psel & penable) ? interrupt_mask : {NUM_INTERRUPTS{1'b0}};
    end

    // Interrupt Service Logic
    always @ (posedge clk) begin
        if (~presetn) begin
            interrupt_idx <= 0;
            interrupt_vector <= 0;
        end else if (interrupt_idx != interrupt_service) begin
            interrupt_idx <= interrupt_idx + 1;
            interrupt_vector <= interrupt_vector + ADDR_WIDTH;
        end
    end

    // Reset Behavior
    initial begin
        interrupt_mask <= {NUM_INTERRUPTS{1'b1}};
        pending_interrupts <= {NUM_INTERRUPTS{1'b0}};
        interrupt_idx <= 0;
        interrupt_vector <= 0;
        pready <= 0;
    end

endmodule
