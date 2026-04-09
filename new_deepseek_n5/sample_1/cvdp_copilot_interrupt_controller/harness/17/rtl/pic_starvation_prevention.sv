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
    reg [3:0] active_mask;
    reg [3:0] service_timer;
    reg timeout_error;
    reg [3:0] next_interrupt_id;
    reg [4:0] max_priority;

    always @posedge rst_n) begin
        current_state = IDLE;
        next_state = IDLE;
        pending_interrupts = 0;
        wait_counters = 0;
        effective_priority = 0;
        active_mask = 0;
        service_timer = 0;
        timeout_error = 0;
        next_interrupt_id = 0;
        max_priority = 0;
    end

    always @negedge reset_interrupts) begin
        current_state = IDLE;
        next_state = IDLE;
        pending_interrupts = 0;
        wait_counters = 0;
        effective_priority = 0;
        active_mask = 0;
        service_timer = 0;
        timeout_error = 0;
        next_interrupt_id = 0;
        max_priority = 0;
    end

    // PRIORITY CALCULATION
    always @negedge rst_n) begin
        if (current_state == PRIORITY_CALC) begin
            effective_priority = static_priority;
            for (int i = 0; i < 10; i++) begin
                if (pending_interrupts & (1 << i)) begin
                    wait_time = wait_counters[i];
                    if (wait_time > STARVATION_THRESHOLD) begin
                        effective_priority[i] = max(effective_priority[i], static_priority[i] + 1);
                    end
                end
            end
        end
    end

    // SERVICE PREPARATION
    always @negedge rst_n) begin
        if (current_state == SERVICE_PREP) begin
            next_interrupt_id = 0;
            service_timer = 0;
        end
    end

    // SERVICING
    always @negedge rst_n) begin
        if (current_state == SERVICING) begin
            if (service_timer == 0) begin
                interrupt_valid = 1;
                interrupt_id = next_interrupt_id;
                service_timer = 3;
            end else begin
                timeout_error = 1;
                current_state = COMPLETION;
            end
        end
    end

    // COMPLETION
    always @negedge rst_n) begin
        if (current_state == COMPLETION) begin
            next_state = IDLE;
        end
    end

    // ERROR
    always @negedge rst_n) begin
        if (current_state == ERROR) begin
            next_state = IDLE;
        end
    end

    // OVERRIDE
    always @negedge rst_n) begin
        if (priority_override_en && current_state == PRIORITY_CALC) begin
            effective_priority[override_interrupt_id] = priority_override;
        end
    end

    // MASKING
    always @negedge rst_n) begin
        if (current_state == IDLE) begin
            active_mask = 0;
        end
    end

    // Update pending interrupts and active_mask based on mask input
    always @* begin
        pending_interrupts = 0;
        for (int i = 0; i < 10; i++) begin
            if ((interrupt_mask & (1 << i)) != 0) begin
                pending_interrupts |= (1 << i);
            end
        end
        active_mask = interrupt_mask;
    end

    // Update wait counters and effective priority
    always @* begin
        for (int i = 0; i < 10; i++) begin
            wait_counters[i] = 0;
            effective_priority[i] = static_priority[i];
        end
    end

    // Final cleanup
    always @* begin
        service_timer = 0;
        timeout_error = 0;
        next_interrupt_id = 0;
    end