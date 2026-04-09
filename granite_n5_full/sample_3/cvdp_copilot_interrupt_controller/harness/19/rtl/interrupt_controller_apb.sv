module interrupt_controller_apb #(
    parameter NUM_ INTERRUPTS = 4,
    parameter ADDR_WIDTH = 8
    )
    (
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_ INTERRUPTS-1:0] interrupt_service,
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

logic [NUM_ INTERRUPTS-1:0] interrupt_mask;
logic servicing;
logic [NUM_ INTERRUPTS-1:0] pending_interrupts;

    // Insert the logic here


endmodule