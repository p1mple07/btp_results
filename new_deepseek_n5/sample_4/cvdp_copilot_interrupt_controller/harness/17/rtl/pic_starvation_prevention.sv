module interrupt_controller (
    input wire clk,
    input wire rst_n,
    input wire reset_interrupts,
    input wire [9:0] interrupt_requests,
    input wire interrupt_ack,
    input wire interrupt_trig,
    input wire [9:0] interrupt_mask,
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
    reg [9:0] active_mask;
    reg [3:0] service_timer;
    reg timeout_error;         
    reg [3:0] next_interrupt_id;
    reg [4:0] max_priority;

    always @posedge clk begin
        if (rst_n) 
            current_state = IDLE;
        else if (reset_interrupts) 
            current_state = IDLE;
        else case (current_state)
            IDLE: 
                if (interrupt_trig) begin
                    next_state = PRIORITY_CALC;
                    next_interrupt_id = 0;
                end
                current_state = IDLE;
            PRIORITY_CALC: 
                // Calculate effective priority based on static and dynamic factors
                // Update priority based on wait time
                for (int i = 0; i < 10; i++) begin
                    wait_counters[i] <= wait_counters[i] + 1;
                    // Apply priority override if enabled
                    if (priority_override_en) begin
                        effective_priority[i] <= (priority_override + effective_priority[i]);
                    end else 
                        effective_priority[i] <= effective_priority[i];
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
                next_state = SERVICE_PREP;
            SERVICE_PREP: 
                // Service the selected interrupt
                if (next_interrupt_id == 0) begin
                    // Apply mask to determine if interrupt is active
                    if ( (interrupt_mask & (1 << next_interrupt_id)) != 0 ) begin
                        interrupt_valid = 1;
                        interrupt_ack = 1;
                        next_state = COMPLETION;
                    end else 
                        // Masked interrupt, do not service
                        next_state = IDLE;
                    end
                end else 
                    next_state = IDLE;
            SERVICING: 
                // Monitor timeout
                service_timer <= service_timer + 1;
                if (service_timer > STARVATION_THRESHOLD) begin
                    next_state = COMPLETION;
                end else 
                    next_state = SERVICING;
            COMPLETION: 
                // Clear serviced interrupt
                next_state = IDLE;
            ERROR: 
                // Handle missed interrupts
                missed_interrupts <= missed_interrupts + (1 << next_interrupt_id);
                next_state = ERROR;
        end
    end

    // Update priority override
    if (priority_override_en) begin
        effective_priority[override_interrupt_id] <= (priority_override + effective_priority[override_interrupt_id]);
    end

    // Update wait counters
    if (next_state != IDLE) begin
        // Apply active_mask to update wait counters
        for (int i = 0; i < 10; i++) begin
            if ( (active_mask & (1 << i)) != 0 ) begin
                wait_counters[i] <= wait_counters[i] + (next_state == SERVICING ? 1 : 0);
            end
        end
    end

    // Reset all states and registers on reset
    always @posedge rst_n or posedge reset_interrupts begin
        current_state = IDLE;
        pending_interrupts = 0;
        wait_counters = 0;
        effective_priority = 0;
        active_mask = 0;
        service_timer = 0;
        timeout_error = 0;
        next_interrupt_id = 0;
        next_state = IDLE;
    end
endmodule