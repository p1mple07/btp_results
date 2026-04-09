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
    logic [NUM_INTERRUPTS-1:0] priority_map [NUM_INTERRUPTS-1:0];
    // Interrupt Vector Table Register
    logic [ADDR_WIDTH-1:0] vector_table [NUM_INTERRUPTS-1:0];

    // Initialize default states and values
    always @ (posedge clk or posedge rst_n) begin
        if (rst_n) begin
            interrupt_mask <= (1 << NUM_INTERRUPTS) - 1; // Enable all interrupts
            interrupt_idx <= (NUM_INTERRUPTS - 1) << $clog2(NUM_INTERRUPTS); // Highest priority index
            interrupt_vector <= vector_table[interrupt_idx];
            pending_interrupts <= (NUM_INTERRUPTS - 1) << $clog2(NUM_INTERRUPTS); // All interrupts pending
            servicing <= 0;
            pready <= 0;
        end else begin
            pready <= 1;
        end
    end

    // Interrupt Arbitration Logic
    always @ (*) begin
        interrupt_idx = 0;
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (interrupt_requests[i] && (pending_interrupts[i] == (NUM_INTERRUPTS - 1) << $clog2(NUM_INTERRUPTS))) begin
                interrupt_idx = i;
                interrupt_service = interrupt_idx;
                servicing <= 1;
                break;
            end
        end
        if (servicing) interrupt_service <= 0;
    end

    // Interrupt Masking Logic
    always @ (posedge clk or posedge rst_n) begin
        if (rst_n) interrupt_mask <= (1 << NUM_INTERRUPTS) - 1;
        else interrupt_mask <= (interrupt_requests | ~interrupt_mask) & (~priority_map);
    end

    // Interrupt Vector Table Access Logic
    always @ (posedge pclk or posedge presetn or posedge rst_n) begin
        if (presetn) begin
            vector_table[0] <= 0x0;
            for (int i = 1; i < NUM_INTERRUPTS; i++) begin
                vector_table[i] <= (vector_table[i-1] + ADDR_WIDTH) & (NUM_INTERRUPTS - 1);
            end
        end
        else vector_table <= vector_table;
    end

    // APB Interface Logic
    always @ (posedge pclk or posedge rst_n) begin
        if (rst_n) begin
            prdata <= (32'b0);
        end else begin
            case (psel)
                1'b0: begin
                    prdata <= (paddr == priority_map) ? pwdata : 32'b0;
                end
                1'b1: begin
                    prdata <= (paddr == interrupt_mask) ? pwdata : 32'b0;
                end
                1'b0: begin
                    prdata <= (paddr == vector_table) ? pwdata : 32'b0;
                end
                default: prdata <= 32'b0;
            endcase
        end
    end

    // CPU Interrupt Acknowledgment Logic
    always @ (posedge clk or posedge rst_n) begin
        if (rst_n) interrupt_service <= (NUM_INTERRUPTS - 1) << $clog2(NUM_INTERRUPTS);
        else if (cpu_interrupt) interrupt_service <= interrupt_idx;
    end

endmodule
