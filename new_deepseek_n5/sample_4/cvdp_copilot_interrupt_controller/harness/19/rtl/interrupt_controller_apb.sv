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

    // Initialize on reset
    always_comb begin
        if (rst_n) begin
            // Initialize priority map
            interrupt_mask = (4'd1);
            pending_interrupts = 0;
            // Initialize vector table
            interrupt_vector = 0x0;
        end
    end

    // APB Read/Write Logic
    always logic [ADDR_WIDTH-1:0] apb_data;
    always_comb begin
        if (pwrite) begin
            apb_data = pwdata;
        end else begin
            apb_data = 0;
        end
    end

    // Interrupt Service Selection
    always logic [NUM_INTERRUPTS-1:0] selected_interrupt;
    always_comb begin
        if (interrupt_requests) begin
            selected_interrupt = 0;
            // Find highest priority interrupt
            for (int i = 0; i < NUM_INTERRUPTS; i++) begin
                if (pending_interrupts & (1 << i)) begin
                    selected_interrupt = i;
                    break;
                end
            end
        end
    end

    // Vector Table Mapping
    always logic [ADDR_WIDTH-1:0] vector_address;
    always_comb begin
        if (selected_interrupt) begin
            vector_address = vector_table[selected_interrupt];
        else begin
            vector_address = 0;
        end
    end

    // APB Interface
    always logic [ADDR_WIDTH-1:0] prvalue;
    always_comb begin
        prvalue = apb_data;
    end

    // APB Ready Handling
    always logic ready;
    always_comb begin
        ready = 0;
        if (psel & penable & (pwrite ^ apb_data)) begin
            // Valid transaction
            ready = 1;
        end
    end

    // Glitch-Free Operation
    always logic valid_transaction;
    always_comb begin
        valid_transaction = 0;
        if (serving) begin
            if (prvalue == prdata) begin
                valid_transaction = 1;
            end
        end
    end

    // Output signals
    output logic cpu_interrupt = cpu_interrupt;
    output logic prvalue = prdata;
    output logic valid_transaction = pready;
    output logic selected_interrupt = interrupt_idx;
    output logic vector_address = interrupt_vector;