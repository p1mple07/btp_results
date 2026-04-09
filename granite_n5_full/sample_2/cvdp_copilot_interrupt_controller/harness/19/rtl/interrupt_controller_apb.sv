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

    // APB Implementation
    always_ff @(posedge clk) begin
        if(psel & penable) begin
            if(pwrite) begin
                // Write Transaction
                if(paddr == REG_VECTOR_TABLE) begin
                    //...
                end else if(paddr == REG_CURRENT_INT) begin
                    //...
                end else begin
                    //...
                end
            end
        } else begin
            //...
        end
    endfunction

endmodule