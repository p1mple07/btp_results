module interrupt_controller (
    input wire clk,
    input wire rst_n,
    input wire reset_interrupts,
    input wire [9:0] interrupt_requests,
    input wire interrupt_ack,
    input wire interrupt_trig,
    input wire [3:0] priority_override,
    input wire [3:0] override_interrupt_id,
    input wire priority_override_en,
    output reg [3:0] interrupt_id,
    output reg interrupt_valid,
    output reg [9:0] interrupt_status,
    output reg [9:0] missed_interrupts,
    output reg starvation_detected
);

    parameter STARVATION_THRESHOLD = 5;

    localparam [2:0] 
        IDLE = 3'b000,
        PRIORITY_CALC = 3'b001,
        SERVICE_PREP = 3'b010,
        SERVICING = 3'b011,
        COMPLETION = 3'b100,
        ERROR = 3'b111;

    reg [2:0] current_state, next_state;
    reg [9:0] pending_interrupts;
    reg [3:0] wait_counters [0:9];
    reg [4:0] effective_priority [0:9];
    reg [3:0] active_mask;
    reg [3:0] service_timer;
    reg timeout_error;
    reg [3:0] next_interrupt_id;
    reg [4:0] max_priority;

    always @(posedge clk or negedge rst_n or negedge reset_interrupts) begin
        if (rst_n & reset_interrupts) begin
            // Reset all states and clear error
            pending_interrupts = 0;
            wait_counters = 0;
            effective_priority = 0;
            active_mask = 0;
            service_timer = 0;
            timeout_error = 0;
            next_interrupt_id = 0;
            max_priority = 0;
            current_state = IDLE;
        end else if (rst_n) begin
            // Reset pending interrupts and clear error
            pending_interrupts = 0;
            wait_counters = 0;
            effective_priority = 0;
            active_mask = 0;
            service_timer = 0;
            timeout_error = 0;
            next_interrupt_id = 0;
            max_priority = 0;
            current_state = IDLE;
        end else begin
            case (current_state)
                IDLE: begin
                    // Check if any interrupts are pending
                    if (pending_interrupts != 0) begin
                        // Calculate effective priority
                        effective_priority = priority_override;
                        for (int i = 0; i < 10; i++) begin
                            if ((active_mask & (1 << i)) != 0) begin
                                effective_priority[i] = priority_override;
                            end else begin
                                effective_priority[i] = wait_counters[i] + 1;
                            end
                        end
                        // Select highest priority interrupt
                        next_interrupt_id = 0;
                        max_priority = effective_priority[0];
                        for (int i = 1; i < 10; i++) begin
                            if (effective_priority[i] > max_priority) begin
                                max_priority = effective_priority[i];
                                next_interrupt_id = i;
                            end
                        end
                        current_state = PRIORITY_CALC;
                    end
                PRIORITY_CALC: begin
                    // Check if any interrupts are pending
                    if (pending_interrupts != 0) begin
                        // Apply priority override if enabled
                        if (priority_override_en & (priority_override[0] != 0)) begin
                            effective_priority = priority_override;
                            next_interrupt_id = priority_override[1];
                            max_priority = priority_override[2];
                        end else begin
                            // Select highest priority interrupt
                            next_interrupt_id = 0;
                            max_priority = effective_priority[0];
                            for (int i = 1; i < 10; i++) begin
                                if (effective_priority[i] > max_priority) begin
                                    max_priority = effective_priority[i];
                                    next_interrupt_id = i;
                                end
                            end
                        end
                        current_state = SERVICE_PREP;
                    end
                PRIORITY_CALC: default begin
                    // No pending interrupts
                    current_state = IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        case (current_state)
            IDLE: begin
                // Check if any interrupts are pending
                if (pending_interrupts != 0) begin
                    // Calculate effective priority
                    effective_priority = priority_override;
                    for (int i = 0; i < 10; i++) begin
                        if ((active_mask & (1 << i)) != 0) begin
                            effective_priority[i] = priority_override;
                        end else begin
                            effective_priority[i] = wait_counters[i] + 1;
                        end
                    end
                    // Select highest priority interrupt
                    next_interrupt_id = 0;
                    max_priority = effective_priority[0];
                    for (int i = 1; i < 10; i++) begin
                        if (effective_priority[i] > max_priority) begin
                            max_priority = effective_priority[i];
                            next_interrupt_id = i;
                        end
                    end
                    // Prepare to service selected interrupt
                    next_state = SERVICING;
                    next_interrupt_id = next_interrupt_id;
                    next_state = SERVICING;
                end
                current_state = IDLE;
            end
            SERVICING: begin
                // Service the selected interrupt
                if (interrupt_mask & (1 << next_interrupt_id)) begin
                    // Check if timeout occurred
                    if (service_timer >= STARVATION_THRESHOLD) begin
                        // Update status and clear error
                        if (starvation_detected) begin
                            // Restore previous status
                            interrupt_status = previous_interrupt_status;
                        end
                        // Set valid bit and reset timer
                        interrupt_valid = 1;
                        service_timer = 0;
                        next_state = COMPLETION;
                    end else begin
                        // Restore previous status
                        interrupt_status = previous_interrupt_status;
                        next_state = COMPLETION;
                    end
                end else begin
                    // Timeout occurred
                    next_state = COMPLETION;
                    if (timeout_error) begin
                        // Restore previous status
                        interrupt_status = previous_interrupt_status;
                        // Clear error
                        timeout_error = 0;
                    end
                end
            end
            COMPLETION: begin
                // Update status and clear error
                if (starvation_detected) begin
                    // Restore previous status
                    interrupt_status = previous_interrupt_status;
                end
                // Clear the serviced interrupt
                next_state = IDLE;
                current_state = IDLE;
            end
            ERROR: begin
                // Clear all pending interrupts
                pending_interrupts = 0;
                // Restore previous status
                interrupt_status = previous_interrupt_status;
                // Clear error
                timeout_error = 0;
                // Reset state
                next_state = IDLE;
                current_state = IDLE;
            end
        endcase
    end

    // Initialize previous state values
    always begin
        previous_interrupt_status = interrupt_status;
    end

endmodule