module interrupt_controller_apb #(
    parameter NUM_ INTERRUPTS = 4,
    parameter ADDR_WIDTH = 8
    )
    (
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_ INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_ INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
    output  logic [$clog2(NUM_ INTERRUPTS)-1:0] interrupt_idx,
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

    always_ff @(posedge clk) begin
        if (interrupt_mask[0]) begin
            servicing <= 1'b0;
        end else begin
            if (interrupt_requests[0]) begin
                servicing <= 1'b1;
            end
        end
    endgenerate
    generate integer i;
        for (i = 0; i < NUM_ INTERRUPTS; i++) begin
            if (interrupt_mask[i] == 1.
    end

endmodule

module interrupt_controller_base #(
NUM_ INTERRUPTS=8)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_ INTERRUPTS-1:0] interrupt_requests,
    input  logic [NUM_ INTERRUPTS-1:0] interrupt_mask,
    input  logic [NUM_ INTERRUPTS-1:0] interrupt_vector_table.

endmodule