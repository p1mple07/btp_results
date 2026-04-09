module interrupt_controller (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         reset_interrupts,
    input  wire [9:0]   interrupt_requests,
    input  wire         interrupt_ack,
    input  wire         interrupt_trig,
    input  wire [9:0]   interrupt_mask,
    input  wire [3:0]   priority_override,
    input  wire [3:0]   override_interrupt_id,
    input  wire         priority_override_en,
    output reg  [3:0]   interrupt_id,
    output reg          interrupt_valid,
    output reg [9:0]    interrupt_status,
    output reg [9:0]    missed_interrupts,
    output reg          starvation_detected
);

    // Parameters for thresholds
    parameter STARVATION_THRESHOLD = 5;
    parameter SERVICE_TIMEOUT      = 10;

    // State encoding
    localparam [2:0] 
        IDLE        = 3'b000,
        PRIORITY_CALC = 3'b001,
        SERVICE_PREP = 3'b010,
        SERVICING    = 3'b011,
        COMPLETION   = 3'b100,
        ERROR        = 3'b111;

    // State and internal registers
    reg [2:0] current_state, next_state;
    reg [9:0] pending_interrupts;
    reg [3:0] wait_counters [0:9];
    reg [4:0] effective_priority [0:9];
    reg [9:0] interrupt_status_reg;
    reg [3:0] service_timer;
    reg timeout_error;
    reg [3:0] next_interrupt_id;
    reg [4:0] max_priority;

    // Main sequential block: state machine and register updates
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state        <= IDLE;
            pending_interrupts   <= 10'b0;
            wait_counters        <= '0;
            effective_priority   <= '0;
            interrupt_status_reg <= 10'b0;
            missed_interrupts    <= 10'b0;
            service_timer        <= 4'b0;
            timeout_error        <= 1'b0;
            starvation_detected  <= 1'b0;
        end
        else if (reset_interrupts) begin
            current_state        <= IDLE;
            pending_interrupts   <= 10'b0;
            wait_counters        <= '0;
            effective_priority   <= '0;
            interrupt_status_reg <= 10'b0;
            missed_interrupts    <= 10'b0;
            service_timer        <= 4'b0;
            timeout_error        <= 1'b0;
            starvation_detected  <= 1'b0;
        end
        else begin
            // Update pending interrupts and missed interrupts on trigger
            for (int i = 0; i < 10; i++) begin
                if (interrupt_trig) begin
                    if (interrupt_requests[i] && ~interrupt_mask[i])
                        pending_interrupts[i] <= 1'b1;
                    else if (interrupt_requests[i] && interrupt_mask[i])
                        missed_interrupts[i] <= missed_interrupts[i] + 1;
                end
                // Increment wait counter if pending; otherwise reset it
                if (pending_interrupts[i])
                    wait_counters[i] <= wait_counters[i] + 1;
                else
                    wait_counters[i] <= 4'b0;
            end

            // Calculate effective priority for each pending interrupt
            for (int i = 0; i < 10; i++) begin
                if (pending_interrupts[i]) begin
                    if (priority_override_en && (i == override_interrupt_id))
                        effective_priority[i] <= priority_override;
                    else if (wait_counters[i] >= STARVATION_THRESHOLD)
                        effective_priority[i] <= (i + 1); // Boost priority if starved
                    else
                        effective_priority[i] <= i; // Assume static priority = index
                end
                else begin
                    effective_priority[i] <= 5'b0;
                end
            end

            // State machine actions and output updates
            case (current_state)
                IDLE: begin
                    interrupt_valid <= 1'b0;
                    service_timer   <= 4'b0;
                end
                SERVICE_PREP: begin
                    interrupt_valid <= 1'b1;
                    interrupt_id    <= next_interrupt_id;
                    // Set the status bit for the selected interrupt
                    interrupt_status_reg <= (1 << next_interrupt_id);
                end
                SERVICING: begin
                    service_timer <= service_timer + 1;
                    if (service_timer >= SERVICE_TIMEOUT)
                        timeout_error <= 1'b1;
                end
                COMPLETION: begin
                    // Clear the serviced interrupt from pending list and wait counter
                    pending_interrupts[next_interrupt_id] <= 1'b0;
                    wait_counters[next_interrupt_id]       <= 4'b0;
                    // Clear the status bit for the serviced interrupt
                    interrupt_status_reg <= interrupt_status_reg & ~(1 << next_interrupt_id);
                    interrupt_valid      <= 1'b0;
                    service_timer        <= 4'b0;
                    timeout_error        <= 1'b0;
                end
                ERROR: begin
                    // In error state, clear the timed-out interrupt and transition back to IDLE
                    pending_interrupts[next_interrupt_id] <= 1'b0;
                    wait_counters[next_interrupt_id]       <= 4'b0;
                    interrupt_status_reg <= interrupt_status_reg & ~(1 << next_interrupt_id);
                    timeout_error        <= 1'b0;
                    current_state        <= IDLE;
                end
                default: ;
            endcase

            // Update current state from next_state computed in combinational logic
            current_state <= next_state;
            // Drive output for interrupt_status
            interrupt_status <= interrupt_status_reg;
        end
    end

    // Combinational logic for next state determination
    always_comb begin
        next_state = current_state; // Default: hold state
        case (current_state)
            IDLE: begin
                if (|pending_interrupts)
                    next_state = PRIORITY_CALC;
            end
            PRIORITY_CALC: 
                next_state = SERVICE_PREP;
            SERVICE_PREP: 
                next_state = SERVICING;
            SERVICING: begin
                if (interrupt_ack)
                    next_state = COMPLETION;
                else if (service_timer >= SERVICE_TIMEOUT)
                    next_state = ERROR;
                else
                    next_state = SERVICING;
            end
            COMPLETION: 
                next_state = IDLE;
            ERROR: 
                next_state = IDLE;
            default: 
                next_state = IDLE;
        endcase
    end

    // Combinational logic: select highest priority pending interrupt
    always_comb begin
        next_interrupt_id = 4'b0;
        max_priority      = 5'b0;
        for (int i = 0; i < 10; i++) begin
            if (pending_interrupts[i]) begin
                if (effective_priority[i] > max_priority) begin
                    max_priority      = effective_priority[i];
                    next_interrupt_id = i;
                end
            end
        end
    end

    // Combinational logic: detect starvation condition
    always_comb begin
        starvation_detected = 1'b0;
        for (int i = 0; i < 10; i++) begin
            if (wait_counters[i] >= STARVATION_THRESHOLD)
                starvation_detected = 1'b1;
        end
    end

endmodule