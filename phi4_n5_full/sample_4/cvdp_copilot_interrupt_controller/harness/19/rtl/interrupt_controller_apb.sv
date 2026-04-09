module interrupt_controller_apb #(
    parameter NUM_INTERRUPTS = 4,
    parameter ADDR_WIDTH     = 8
)
(
    // Interrupt Controller Ports
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
    output logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    
    // APB Interface Ports
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

    // Internal registers for APB-configurable registers
    reg [31:0] priority_map [0:NUM_INTERRUPTS-1];
    reg [31:0] vector_table  [0:NUM_INTERRUPTS-1];
    reg [NUM_INTERRUPTS-1:0] interrupt_mask;
    
    // Internal registers for interrupt logic
    reg [NUM_INTERRUPTS-1:0] pending_interrupts;
    reg [$clog2(NUM_INTERRUPTS)-1:0] current_interrupt_idx;
    reg [ADDR_WIDTH-1:0] current_interrupt_vector;

    //-------------------------------------------------------------------------
    // APB Interface Logic (operating on pclk/presetn)
    //-------------------------------------------------------------------------
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            integer i;
            for(i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                // Default: priority_map[i] = i (sequential values: 0,1,2,...)
                priority_map[i] <= i;
                // Default: vector_table[i] = i*4 (e.g., 0x0, 0x4, 0x8, ...)
                vector_table[i]  <= i * 4;
            end
            // Default: All interrupts enabled (mask bits = 1)
            interrupt_mask <= {NUM_INTERRUPTS{1'b1}};
            prdata         <= 32'd0;
            pready         <= 1'b0;
        end
        else begin
            pready <= 1'b0; // Default: no valid transaction
            if (psel && penable) begin
                pready <= 1'b1;
                if (pwrite) begin
                    // Write transaction: update registers based on paddr
                    case (paddr)
                        8'd0: begin
                             // REG_PRIORITY_MAP: lower 8 bits = index; upper 24 bits = new priority
                             int idx = pwdata[7:0];
                             if (idx < NUM_INTERRUPTS)
                                 priority_map[idx] <= pwdata[31:8];
                        end
                        8'd1: begin
                             // REG_INTERRUPT_MASK: update lower NUM_INTERRUPTS bits
                             interrupt_mask <= pwdata[0:NUM_INTERRUPTS-1];
                        end
                        8'd2: begin
                             // REG_VECTOR_TABLE: lower 8 bits = index; upper 24 bits = new vector address
                             int idx = pwdata[7:0];
                             if (idx < NUM_INTERRUPTS)
                                 vector_table[idx] <= pwdata[31:8];
                        end
                        default: begin
                             // Invalid address: do nothing
                        end
                    endcase
                end
                else begin
                    // Read transaction: output register value based on paddr
                    case (paddr)
                        8'd0: begin
                             // REG_PRIORITY_MAP: read entry specified by index in lower 8 bits of pwdata
                             int idx = pwdata[7:0];
                             prdata <= {24'd0, (idx < NUM_INTERRUPTS ? priority_map[idx] : 32'd0)};
                        end
                        8'd1: begin
                             // REG_INTERRUPT_MASK: return mask bits in lower bits
                             prdata <= {32-NUM_INTERRUPTS{1'b0}, interrupt_mask};
                        end
                        8'd2: begin
                             // REG_VECTOR_TABLE: read entry specified by index in lower 8 bits of pwdata
                             int idx = pwdata[7:0];
                             prdata <= {24'd0, (idx < NUM_INTERRUPTS ? vector_table[idx] : 32'd0)};
                        end
                        8'd3: begin
                             // REG_PENDING: return pending interrupts in lower bits
                             prdata <= {32-NUM_INTERRUPTS{1'b0}, pending_interrupts};
                        end
                        8'd4: begin
                             // REG_CURRENT_INT: return current interrupt index in lower bits
                             prdata <= {32-NUM_INTERRUPTS{1'b0}, current_interrupt_idx};
                        end
                        default: begin
                             // Invalid address: return 0
                             prdata <= 32'd0;
                        end
                    endcase
                end
            end
        end
    end

    //-------------------------------------------------------------------------
    // Main Interrupt Logic (operating on clk/rst_n)
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pending_interrupts         <= '0;
            current_interrupt_idx      <= '0;
            current_interrupt_vector   <= '0;
        end
        else begin
            // Latch external interrupt requests (glitch-free assumed)
            pending_interrupts <= pending_interrupts | interrupt_requests;
            
            // Arbitration: select the highest-priority pending and enabled interrupt
            integer i;
            reg found;
            reg [NUM_INTERRUPTS-1:0] temp_priority;
            reg [$clog2(NUM_INTERRUPTS)-1:0] temp_idx;
            found = 1'b0;
            temp_idx = '0;
            for(i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                if (pending_interrupts[i] && interrupt_mask[i]) begin
                    if (!found) begin
                        found       = 1'b1;
                        temp_idx    = i;
                        temp_priority = priority_map[i];
                    end
                    else if (priority_map[i] < temp_priority) begin
                        temp_idx    = i;
                        temp_priority = priority_map[i];
                    end
                end
            end

            if (found) begin
                // If the CPU acknowledges the current interrupt, clear its pending bit
                if (cpu_ack && (current_interrupt_idx == temp_idx))
                    pending_interrupts[temp_idx] <= 1'b0;
                current_interrupt_idx      <= temp_idx;
                current_interrupt_vector   <= vector_table[temp_idx];
            end
            else begin
                current_interrupt_idx      <= '0;
                current_interrupt_vector   <= '0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // Output Assignments
    //-------------------------------------------------------------------------
    // Drive the interrupt_service vector: only the selected interrupt is asserted.
    always_comb begin
        interrupt_service = '0;
        if (current_interrupt_idx < NUM_INTERRUPTS)
            interrupt_service[current_interrupt_idx] = 1'b1;
    end

    // Assert cpu_interrupt when any interrupt is pending.
    assign cpu_interrupt = (|pending_interrupts);
    assign interrupt_idx = current_interrupt_idx;
    assign interrupt_vector = current_interrupt_vector;

endmodule