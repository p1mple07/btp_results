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

    // Define starvation threshold (cycles)
    parameter STARVATION_THRESHOLD = 5;

    // State encoding
    localparam [2:0] 
        IDLE           = 3'b000,
        PRIORITY_CALC  = 3'b001,
        SERVICE_PREP   = 3'b010,
        SERVICING      = 3'b011,
        COMPLETION     = 3'b100,
        ERROR          = 3'b111;

    // State and internal registers
    reg [2:0] current_state, next_state;
    reg [9:0] pending_interrupts;
    // Use 5-bit counters to accommodate STARVATION_THRESHOLD
    reg [4:0] wait_counters [0:9];
    reg [4:0] effective_priority [0:9];
    reg [9:0] active_mask;
    reg [3:0] service_timer;
    reg timeout_error;
    reg [3:0] next_interrupt_id;
    reg [4:0] max_priority;

    // Main state machine and logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset: clear all registers
            current_state          <= IDLE;
            pending_interrupts     <= 10'b0;
            wait_counters          <= '{default: 5'd0};
            effective_priority     <= '{default: 5'd0};
            interrupt_status       <= 10'b0;
            missed_interrupts      <= 10'b0;
            starvation_detected    <= 1'b0;
            service_timer          <= 4'd0;
            timeout_error          <= 1'b0;
            interrupt_id           <= 4'd0;
            interrupt_valid        <= 1'b0;
        end else if (reset_interrupts) begin
            // Synchronous reset of interrupt-related registers
            pending_interrupts     <= 10'b0;
            wait_counters          <= '{default: 5'd0};
            effective_priority     <= '{default: 5'd0};
            interrupt_status       <= 10'b0;
            missed_interrupts      <= 10'b0;
            starvation_detected    <= 1'b0;
            service_timer          <= 4'd0;
            timeout_error          <= 1'b0;
            interrupt_id           <= 4'd0;
            interrupt_valid        <= 1'b0;
        end else begin
            // Update active mask from input
            active_mask <= interrupt_mask;

            // Update pending_interrupts and wait_counters based on new requests and mask
            for (int i = 0; i < 10; i = i + 1) begin
                if (interrupt_requests[i] && !interrupt_mask[i]) begin
                    pending_interrupts[i] <= 1'b1;
                    wait_counters[i]      <= wait_counters[i] + 1;
                end else begin
                    // If not requested, ensure wait counter is reset
                    wait_counters[i] <= 5'd0;
                end
            end

            // Update effective priority for each pending interrupt.
            // Base priority is assumed to be the interrupt index.
            // Priority override is applied if enabled for the specific interrupt.
            for (int i = 0; i < 10; i = i + 1) begin
                if (pending_interrupts[i]) begin
                    if (priority_override_en && (override_interrupt_id == i))
                        effective_priority[i] <= priority_override;
                    else
                        effective_priority[i] <= i + wait_counters[i];
                end else begin
                    effective_priority[i] <= 5'd0;
                end
            end

            // State Machine Transitions
            case (current_state)
                IDLE: begin
                    // If any interrupt is pending, move to priority calculation
                    if (|pending_interrupts)
                        current_state <= PRIORITY_CALC;
                    else
                        current_state <= IDLE;
                end

                PRIORITY_CALC: begin
                    // Determine the highest priority interrupt
                    max_priority   <= 5'd0;
                    next_interrupt_id <= 4'd0;
                    for (int i = 0; i < 10; i = i + 1) begin
                        if (pending_interrupts[i]) begin
                            if (effective_priority[i] > max_priority) begin
                                max_priority         <= effective_priority[i];
                                next_interrupt_id    <= i;
                            end
                        end
                    end

                    // Check for starvation: if any wait counter exceeds threshold, assert starvation_detected
                    for (int i = 0; i < 10; i = i + 1) begin
                        if (wait_counters[i] >= STARVATION_THRESHOLD)
                            starvation_detected <= 1'b1;
                    end

                    // Transition to service preparation
                    current_state <= SERVICE_PREP;
                end

                SERVICE_PREP: begin
                    // Prepare to service the selected interrupt
                    interrupt_id    <= next_interrupt_id;
                    interrupt_valid <= 1'b1;
                    // Set the corresponding bit in interrupt_status
                    interrupt_status[next_interrupt_id] <= 1'b1;
                    // Transition to servicing state
                    current_state <= SERVICING;
                end

                SERVICING: begin
                    // Wait for the system to acknowledge the interrupt
                    if (interrupt_ack) begin
                        service_timer <= 4'd0;
                        current_state <= COMPLETION;
                    end else begin
                        service_timer <= service_timer + 1;
                        // Timeout detection: if service_timer exceeds a threshold, go to ERROR state
                        if (service_timer >= 4'd8) begin
                            timeout_error <= 1'b1;
                            current_state <= ERROR;
                        end
                    end
                end

                COMPLETION: begin
                    // Clear the serviced interrupt from pending list and reset its counters
                    pending_interrupts[next_interrupt_id] <= 1'b0;
                    wait_counters[next_interrupt_id]      <= 5'd0;
                    effective_priority[next_interrupt_id] <= 5'd0;
                    // Clear the serviced bit in interrupt_status
                    interrupt_status[next_interrupt_id] <= 1'b0;
                    // Deassert interrupt_valid
                    interrupt_valid <= 1'b0;
                    // Return to idle state
                    current_state <= IDLE;
                end

                ERROR: begin
                    // Handle error: clear all pending interrupts and related registers
                    pending_interrupts     <= 10'b0;
                    wait_counters          <= '{default: 5'd0};
                    effective_priority     <= '{default: 5'd0};
                    timeout_error          <= 1'b0;
                    current_state          <= IDLE;
                end

                default: current_state <= IDLE;
            endcase
        end
    end

endmodule