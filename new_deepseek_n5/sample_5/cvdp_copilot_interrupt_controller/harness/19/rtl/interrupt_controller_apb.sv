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

    // Initialize registers on reset
    always_comb begin
        if (rst_n) begin
            // Reset all registers to default values
            priority_map = 0;
            interrupt_mask = 1;
            vector_table = 0;
            pending_interrupts = 0;
            cpu_interrupt = 0;
        end
    end

    // APB Read/Write Transactions
    always_ff @*begin
        if (pwrite & psel & penable) begin
            // Write transaction
            case (paddr)
                0: interrupt_mask = pwdata;
                1: priority_map = pwdata;
                2: vector_table = pwdata;
                3: pending_interrupts = pwdata;
                default: $assert("Invalid APB address");
            endcase
        else if (~pwrite & psel & penable) begin
            // Read transaction
            case (paddr)
                0: prdata = interrupt_mask;
                1: prdata = priority_map;
                2: prdata = vector_table;
                3: prdata = pending_interrupts;
                default: $assert("Invalid APB address");
            endcase
        end
    end

    // Handle CPU Acknowledgment
    cpu_ack = !pending_interrupts;

    // Arbitration logic
    always_ff @*begin
        if (rst_n) cpu_interrupt = 0;
    end
    always_ff @*begin
        if (rst_n) begin
            servicing = 0;
            interrupt_idx = -1;
            interrupt_vector = 0;
            prdata = 0;
        end
    end

    // Select highest priority interrupt when pending
    if (rst_n) return;
    if (serving) return;
    if (pending_interrupts) begin
        // Find highest priority interrupt
        servicing = 1;
        interrupt_idx = 0;
        interrupt_vector = 0;
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (pending_interrupts & (1 << i)) begin
                interrupt_idx = $clog2(1 << i);
                interrupt_vector = vector_table[i];
                break;
            end
        end
    end

    // Update CPU interrupt
    cpu_interrupt = servicing;

    endmodule