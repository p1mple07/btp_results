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
    logic [NUM_INTERRUPTS-1:0] vector_table;

    // Initialize default values
    initial begin
        interrupt_mask = (1 << NUM_INTERRUPTS) - 1;
        pending_interrupts = 0;
        vector_table = 0;
        // Initialize priority map with default priorities
        for (logic i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
            priority_map[i] = i;
        end
    end

    // APB clock generation
    pclk = !clk;

    // APB ready handling
    pready = 0;
    always_comb begin
        if (serving) begin
            pready = 1;
            servicing = false;
        end
    end

    // Handle interrupt requests
    always logic begin
        if (rst_n) begin
            servicing = false;
            pending_interrupts = 0;
            vector_table = 0;
            // Initialize priority map on reset
            for (logic i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                priority_map[i] = i;
            end
        end else begin
            if (interrupt_requests) begin
                // Update pending interrupts
                pending_interrupts = pending_interrupts | interrupt_requests;
                
                // Select highest priority interrupt
                servicing = true;
                interrupt_idx = 0;
                interrupt_vector = 0;
                logic max_priority = 0;
                logic max_index = 0;
                
                for (logic i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                    if (priority_map[i] > max_priority) begin
                        max_priority = priority_map[i];
                        max_index = i;
                    end
                end
                interrupt_idx = max_index;
                interrupt_vector = vector_table[max_index];
            end
        end
    end

    // APB write operation
    if (psel & penable & pwrite) begin
        prdata = pwdata;
    end

    // APB read operation
    if (psel & penable & ~pwrite) begin
        prdata = paddr;
    end

    endmodule