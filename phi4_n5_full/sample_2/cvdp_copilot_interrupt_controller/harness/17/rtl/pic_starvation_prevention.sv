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

    // Parameters for thresholds and timeouts
    parameter STARVATION_THRESHOLD = 5;
    parameter SERVICE_TIMEOUT      = 16;

    // State encoding
    localparam [2:0] 
        IDLE          = 3'b000,
        PRIORITY_CALC = 3'b001,
        SERVICE_PREP  = 3'b010,
        SERVICING     = 3'b011,
        COMPLETION    = 3'b100,
        ERROR         = 3'b111;

    // State registers
    reg [2:0] current_state, next_state;
    // Registers for pending interrupts and timing
    reg [9:0] pending_interrupts;
    reg [3:0] wait_counters [0:9];
    reg [4:0] effective_priority [0:9];
    reg [3:0] service_timer;
    reg timeout_error;
    reg [3:0] next_interrupt_id;

    // Static priority array: higher index means higher priority (9 is highest, 0 is lowest)
    localparam integer static_priority [0:9] = '{9,8,7,6,5,4,3,2,1,0};

    //-------------------------------------------------------------------------
    // Main state machine: handles new requests, priority calculation, service,
    // completion, and error conditions.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state         <= IDLE;
            pending_interrupts    <= 10'b0;
            missed_interrupts     <= 10'b0;
            for (int i = 0; i < 10; i = i + 1) begin
                wait_counters[i]        <= 4'd0;
                effective_priority[i]   <= 5'd0;
            end
            interrupt_id          <= 4'd0;
            interrupt_valid       <= 1'b0;
            interrupt_status      <= 10'b0;
            service_timer         <= 4'd0;
            timeout_error         <= 1'b0;
            starvation_detected   <= 1'b0;
        end 
        else if (reset_interrupts) begin
            current_state         <= IDLE;
            pending_interrupts    <= 10'b0;
            missed_interrupts     <= 10'b0;
            for (int i = 0; i < 10; i = i + 1) begin
                wait_counters[i]        <= 4'd0;
                effective_priority[i]   <= 5'd0;
            end
            interrupt_id          <= 4'd0;
            interrupt_valid       <= 1'b0;
            interrupt_status      <= 10'b0;
            service_timer         <= 4'd0;
            timeout_error         <= 1'b0;
            starvation_detected   <= 1'b0;
        end 
        else begin
            // Default assignments to avoid latches
            next_state            = current_state;
            interrupt_valid       <= 1'b0;
            interrupt_id          <= 4'd0;
            service_timer         <= service_timer; // hold current value
            timeout_error         <= timeout_error; // hold current value

            case (current_state)
                IDLE: begin
                    // On trigger, sample new interrupt requests.
                    if (interrupt_trig) begin
                        for (int i = 0; i < 10; i = i + 1) begin
                            if (interrupt_requests[i]) begin
                                if (interrupt_mask[i]) begin
                                    // Enable interrupt: mark as pending if not already pending.
                                    if (!pending_interrupts[i])
                                        pending_interrupts[i] <= 1'b1;
                                    // Reset wait counter and set effective priority.
                                    wait_counters[i] <= 4'd0;
                                    if (priority_override_en && (override_interrupt_id == i))
                                        effective_priority[i] <= priority_override;
                                    else
                                        effective_priority[i] <= static_priority[i];
                                end 
                                else begin
                                    // Masked interrupt: record as missed.
                                    missed_interrupts[i] <= missed_interrupts[i] + 1;
                                end
                            end
                        end
                    end

                    // Increment wait counters for all pending interrupts.
                    for (int i = 0; i < 10; i = i + 1) begin
                        if (pending_interrupts[i])
                            wait_counters[i] <= wait_counters[i] + 1;
                    end

                    // Check for starvation: if any pending interrupt waits longer than threshold.
                    for (int i = 0; i < 10; i = i + 1) begin
                        if (pending_interrupts[i] && wait_counters[i] > STARVATION_THRESHOLD)
                            starvation_detected <= 1'b1;
                        else
                            starvation_detected <= 1'b0;
                    end

                    // Transition to priority calculation if any interrupt is pending.
                    if (pending_interrupts != 10'b0)
                        next_state = PRIORITY_CALC;
                    else
                        next_state = IDLE;
                end

                PRIORITY_CALC: begin
                    // Recalculate effective priority for each pending interrupt.
                    for (int i = 0; i < 10; i = i + 1) begin
                        if (pending_interrupts[i]) begin
                            if (priority_override_en && (override_interrupt_id == i))
                                effective_priority[i] <= priority_override;
                            else
                                effective_priority[i] <= static_priority[i] +
                                    ((wait_counters[i] >= STARVATION_THRESHOLD) ?
                                     (wait_counters[i] - STARVATION_THRESHOLD) : 0);
                        end
                    end
                    next_state = SERVICE_PREP;
                end

                SERVICE_PREP: begin
                    // Prepare to service the highest priority interrupt.
                    interrupt_valid <= 1'b1;
                    // The selected interrupt ID is computed combinatorially.
                    interrupt_id <= next_interrupt_id;
                    // Set the corresponding bit in interrupt_status.
                    interrupt_status <= (1 << next_interrupt_id);
                    service_timer <= 4'd0;
                    next_state = SERVICING;
                end

                SERVICING: begin
                    service_timer <= service_timer + 1;
                    if (interrupt_ack)
                        next_state = COMPLETION;
                    else if (service_timer >= SERVICE_TIMEOUT)
                        next_state = ERROR;
                    else
                        next_state = SERVICING;
                end

                COMPLETION: begin
                    // Clear the serviced interrupt.
                    pending_interrupts[next_interrupt_id] <= 1'b0;
                    wait_counters[next_interrupt_id] <= 4'd0;
                    effective_priority[next_interrupt_id] <= 5'd0;
                    // Clear the serviced bit from interrupt_status.
                    interrupt_status <= interrupt_status & ~(1 << next_interrupt_id);
                    service_timer <= 4'd0;
                    timeout_error <= 1'b0;
                    // If more interrupts remain, go back to priority calculation.
                    if (pending_interrupts != 10'b0)
                        next_state = PRIORITY_CALC;
                    else
                        next_state = IDLE;
                end

                ERROR: begin
                    // In error state, clear the serviced interrupt and reset timing.
                    pending_interrupts[next_interrupt_id] <= 1'b0;
                    wait_counters[next_interrupt_id] <= 4'd0;
                    effective_priority[next_interrupt_id] <= 5'd0;
                    interrupt_status <= interrupt_status & ~(1 << next_interrupt_id);
                    service_timer <= 4'd0;
                    timeout_error <= 1'b0;
                    next_state = IDLE;
                end

                default: next_state = IDLE;
            endcase

            current_state <= next_state;
        end
    end

    //-------------------------------------------------------------------------
    // Combinational logic to select the highest priority pending interrupt.
    // If multiple interrupts have the same priority, the lowest index is chosen.
    //-------------------------------------------------------------------------
    always_comb begin
        // Default selection: lowest index.
        next_interrupt_id = 4'd0;
        for (int i = 0; i < 10; i = i + 1) begin
            if (pending_interrupts[i]) begin
                if (effective_priority[i] > effective_priority[next_interrupt_id])
                    next_interrupt_id = i;
            end
        end
    end

endmodule