module interrupt_controller_apb #(
    parameter NUM_INTERRUPTS = 4,
    parameter ADDR_WIDTH = 8
)(
    // Core Interrupt Signals
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

    //-------------------------------------------------------------------------
    // Internal APB-Controlled Configuration Registers
    //-------------------------------------------------------------------------

    // priority_map: array of NUM_INTERRUPTS 32-bit registers.
    // Each register is formatted as {priority (31:8), index (7:0)}.
    reg [31:0] priority_map_array [0:NUM_INTERRUPTS-1];

    // interrupt_mask: 32-bit register; lower NUM_INTERRUPTS bits used.
    reg [31:0] interrupt_mask_reg;

    // vector_table: array of NUM_INTERRUPTS 32-bit registers.
    // Each register is formatted as {vector address (31:8), index (7:0)}.
    reg [31:0] vector_table_array [0:NUM_INTERRUPTS-1];

    //-------------------------------------------------------------------------
    // Internal Interrupt Logic Registers
    //-------------------------------------------------------------------------

    // pending_interrupts: one bit per interrupt.
    reg [NUM_INTERRUPTS-1:0] pending_interrupts;

    // current_interrupt: index of the currently serviced interrupt.
    reg [$clog2(NUM_INTERRUPTS)-1:0] current_interrupt;

    // Synchronizer registers for external interrupt_requests (2-stage)
    reg [NUM_INTERRUPTS-1:0] interrupt_req_sync1;
    reg [NUM_INTERRUPTS-1:0] interrupt_req_sync2;

    //-------------------------------------------------------------------------
    // APB Interface (pclk Domain)
    //-------------------------------------------------------------------------

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            // Reset APB registers to default values
            integer i;
            // Reset priority_map: for each interrupt, set priority = index and store index.
            for (i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                priority_map_array[i] <= {i, i};  // {priority, index}
            end
            // Reset interrupt_mask: all interrupts enabled (1 for each bit)
            interrupt_mask_reg <= {NUM_INTERRUPTS{1'b1}};
            // Reset vector_table: sequential addresses (e.g., 0x0, 0x4, 0x8, ...)
            for (i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
                vector_table_array[i] <= { {24{1'b0}}, 4*i }; // {vector, index}
            end
        end
        else if (psel && penable) begin
            if (pwrite) begin
                // Write Transaction
                case (paddr)
                    8'h0: begin
                        // REG_PRIORITY_MAP: pwdata[7:0] is the interrupt index,
                        // pwdata[31:8] is the new priority.
                        if (pwdata[7:0] < NUM_INTERRUPTS)
                            priority_map_array[pwdata[7:0]] <= {pwdata[31:8], pwdata[7:0]};
                    end
                    8'h1: begin
                        // REG_INTERRUPT_MASK: update mask register (lower NUM_INTERRUPTS bits)
                        interrupt_mask_reg <= pwdata;
                    end
                    8'h2: begin
                        // REG_VECTOR_TABLE: pwdata[7:0] is the interrupt index,
                        // pwdata[31:8] is the new vector address.
                        if (pwdata[7:0] < NUM_INTERRUPTS)
                            vector_table_array[pwdata[7:0]] <= {pwdata[31:8], pwdata[7:0]};
                    end
                    default: ; // Undefined address: no operation.
                endcase
            end
            else begin
                // Read Transaction
                case (paddr)
                    8'h3: begin
                        // REG_PENDING: return pending_interrupts packed in lower bits.
                        prdata <= { {24{1'b0}}, pending_interrupts };
                    end
                    8'h4: begin
                        // REG_CURRENT_INT: return current_interrupt (zero-extended).
                        prdata <= { {24{1'b0}}, current_interrupt };
                    end
                    default: prdata <= 32'h0;
                endcase
                pready <= 1'b1;  // Assert ready for immediate access.
            end
        end
        else begin
            pready <= 1'b0;  // No valid transaction: de-assert ready.
        end
    end

    //-------------------------------------------------------------------------
    // Interrupt Logic (clk Domain)
    //-------------------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pending_interrupts <= '0;
            current_interrupt  <= {(NUM_INTERRUPTS){1'b1}}; // Invalid index (all ones)
            cpu_interrupt      <= 1'b0;
        end
        else begin
            // Two-stage synchronizer for external interrupt_requests.
            interrupt_req_sync1 <= interrupt_requests;
            interrupt_req_sync2 <= interrupt_req_sync1;
            
            // Update pending_interrupts:
            // If an interrupt is requested and not masked, assert its pending bit.
            // If cpu_ack is asserted for the current interrupt, clear its pending bit.
            integer j;
            for (j = 0; j < NUM_INTERRUPTS; j = j + 1) begin
                if (cpu_ack && (current_interrupt == j))
                    pending_interrupts[j] <= 1'b0;
                else if (interrupt_req_sync2[j] && ~interrupt_mask_reg[j])
                    pending_interrupts[j] <= 1'b1;
                // Otherwise, retain the previous pending state.
            end
            
            // Assert cpu_interrupt if any interrupt is pending.
            cpu_interrupt <= |pending_interrupts;
        end
    end

    //-------------------------------------------------------------------------
    // Interrupt Arbitration (Combinational)
    //-------------------------------------------------------------------------
    // Select the highest-priority pending interrupt based on priority_map_array.
    // Each entry in priority_map_array is formatted as {priority, index}.
    logic [$clog2(NUM_INTERRUPTS)-1:0] selected_int;
    logic [31:0] max_priority;
    integer k;
    always_comb begin
        // Default: no valid interrupt selected (invalid index: all ones)
        selected_int = {(NUM_INTERRUPTS){1'b1}};
        max_priority = 32'h0;
        for (k = 0; k < NUM_INTERRUPTS; k = k + 1) begin
            if (pending_interrupts[k]) begin
                // Extract the priority value (bits [31:8])
                if (priority_map_array[k][31:8] > max_priority) begin
                    max_priority = priority_map_array[k][31:8];
                    selected_int = k;
                end
                else if (priority_map_array[k][31:8] == max_priority && k < selected_int) begin
                    selected_int = k;
                end
            end
        end
    end

    // Latch the selected interrupt index.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_interrupt <= {(NUM_INTERRUPTS){1'b1}}; // Invalid on reset
        else
            current_interrupt <= selected_int;
    end

    //-------------------------------------------------------------------------
    // Output Assignments
    //-------------------------------------------------------------------------

    // Drive interrupt_service: a one-hot vector with the selected interrupt.
    assign interrupt_service = (current_interrupt != {(NUM_INTERRUPTS){1'b1}})
                                ? (1'b1 << current_interrupt)
                                : '0;
    // Drive interrupt_idx with the current interrupt index.
    assign interrupt_idx = current_interrupt;
    // Drive interrupt_vector with the vector address from vector_table_array.
    assign interrupt_vector = (current_interrupt != {(NUM_INTERRUPTS){1'b1}})
                                ? vector_table_array[current_interrupt]
                                : 8'h0;

endmodule