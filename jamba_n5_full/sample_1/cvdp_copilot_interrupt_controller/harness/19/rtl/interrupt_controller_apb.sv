module interrupt_controller_apb #(
    parameter NUM_INTERRUPTS = 4,
    parameter ADDR_WIDTH = 8
)
(
    input logic clk,
    input logic rst_n,
    input logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic cpu_interrupt,
    input logic cpu_ack,
    output logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
    output logic [ADDR_WIDTH-1:0] interrupt_vector,

    input logic pclk,
    input logic presetn,
    input logic psel,
    input logic penable,
    input logic pwrite,
    input logic [ADDR_WIDTH-1:0] paddr,
    input logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic pready
);

reg [NUM_INTERRUPTS-1:0] priority_map;
reg [NUM_INTERRUPTS-1:0] interrupt_mask;
reg [NUM_INTERRUPTS-1:0] pending_interrupts;
reg [ADDR_WIDTH-1:0] vector_table[0:7];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        priority_map <= {repeat(NUM_INTERRUPTS) {0}};
        interrupt_mask <= {repeat(NUM_INTERRUPTS) {1'b1}};
        vector_table[0] <= 0;
        vector_table[1] <= 4;
        vector_table[2] <= 8;
        // ... the remaining registers are left at 0 as per default
        pending_interrupts <= 8'bzero;
        interrupt_service <= 8'bzero;
        cpu_interrupt <= 1'b0;
        cpu_ack <= 1'b0;
        interrupt_idx <= 8'bzero;
        interrupt_vector <= 8'bzero;
    end else begin
        // Highest priority interrupt
        int max_pri = -1;
        int max_idx = -1;
        for (int i = 0; i < NUM_INTERRUPTS; i++) begin
            if (interrupt_mask[i] && (priority_map[i] > max_pri)) begin
                max_pri = priority_map[i];
                max_idx = i;
            end
        end
        if (max_idx != -1) begin
            interrupt_service <= interrupt_requests[max_idx];
            interrupt_idx <= max_idx;
            interrupt_vector <= vector_table[max_idx];
        end
    end
end

always @(posedge pclk or negedge presetn) begin
    if (presetn) begin
        pclk <= pclk;
        psel <= 1'b1;
        penable <= 1'b1;
        pwrite <= 1'b0;
        pready <= 1'b0;
    end else begin
        pclk <= pclk;
        psel <= psel;
        penable <= penable;
        pwrite <= pwrite;
        pready <= pready;
    end
end

endmodule
