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
    logic [NUM_INTERRUPTS-1:0] vector_index;
    logic [ADDR_WIDTH-1:0]     vector_address;

    // Initialize registers on reset
    initial begin
        case (rst_n)
            1: interrupt_mask = (1 << NUM_INTERRUPTS) - 1;
            0: pending_interrupts = 0;
            0: vector_index = 0;
            0: vector_address = 0;
        endcase
    end

    // APB transaction handling
    always_ff @* (pwrite or psel or penable) begin
        if (pwrite) begin
            case (paddr)
                0x0: priority_map = pwdata;
                0x1: interrupt_mask = pwdata;
                0x2: vector_table = pwdata;
                default: priority_map = 0;
            endcase
        else if (psel && penable) begin
            case (paddr)
                0x0: prdata = priority_map;
                0x1: prdata = interrupt_mask;
                0x2: prdata = vector_table;
                default: prdata = 0;
            endcase
        end
    end

    // Interrupt handling
    always_ff @* (interrupt_requests) begin
        if (serving) return;
        
        // Find highest priority interrupt
        vector_index = 0;
        vector_address = 0;
        pending_interrupts = 0;
        for (vector_index = 0; vector_index < NUM_INTERRUPTS; vector_index++) begin
            if (pending_interrupts & (1 << vector_index)) begin
                vector_address = vector_table[$clog2(NUM_INTERRUPTS)-1:0][vector_index];
                pending_interrupts = pending_interrupts ^ (1 << vector_index);
                servicing = 1;
                break;
            end
        end

        // Service the interrupt
        interrupt_vector = vector_address;
        cpu_interrupt = 1;
        servicing = 0;

        // Update vector_table if needed
        case (vector_address)
            0x0: vector_table[$clog2(NUM_INTERRUPTS)-1:0][0] = 0x4;
            0x4: vector_table[$clog2(NUM_INTERRUPTS)-1:0][1] = 0x8;
            default: break;
        endcase
    end

    // APB readiness
    pready = servicing;
endmodule