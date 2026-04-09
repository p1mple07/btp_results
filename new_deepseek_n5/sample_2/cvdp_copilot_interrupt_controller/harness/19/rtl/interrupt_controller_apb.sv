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
    begin
        if (rst_n) begin
            // Reset all registers
            pending_interrupts = 0;
            interrupt_mask = (1 << NUM_INTERRUPTS) - 1;
            vector_table = 0;
            // Initialize priority map
            for (logic i = 0; i < NUM_INTERRUPTS; i++) begin
                priority_map[i] = i;
            end
            servicing = 0;
            pready = 0;
        end
    end

    // Process interrupt requests
    always logic clock_edge #+1 begin
        if (rst_n) begin
            pending_interrupts = 0;
            servicing = 0;
            pready = 0;
        end
        else if (interrupt_requests) begin
            pending_interrupts = pending_interrupts | ((1 << interrupt_requests) - 1);
        end

        // Select highest priority interrupt
        if (serving) begin
            // Find highest set bit in pending_interrupts
            interrupt_idx = 0;
            for (logic i = 0; i < NUM_INTERRUPTS; i++) begin
                if (pending_interrupts & (1 << i)) begin
                    interrupt_idx = i;
                    break;
                end
            end

            // Prepare for APB communication
            if (interrupt_idx != -1) begin
                // Set APB signals
                psel = 1;
                penable = 1;
                pwrite = 1;
                paddr = vector_table[interrupt_idx];
                prdata = 0;

                // Send vector address to APB
                pwrite = 1;
                pclk = 1;
                pready = 1;
                pwrite = 0;
            end else begin
                // No pending interrupts
                pready = 0;
            end
        end

        // Update pending_interrupts
        pending_interrupts = pending_interrupts ^ (1 << interrupt_idx);
    end

    // Cleanup
    always logic clock_edge #+1 begin
        if (pready) begin
            servicing = 0;
            pready = 0;
        end
    end