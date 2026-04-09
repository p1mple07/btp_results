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

    always @posedge clk or (!rst_n & asserted(reset_interrupts)) begin
        current_state = IDLE;
        next_state = IDLE;
    end

    always @negedge rst_n begin
        current_state = IDLE;
        next_state = IDLE;
    end

    // State: IDLE
    always @negedge rst_n or (!rst_n & !reset_interrupts) begin
        if (interrupt_trig) begin
            current_state = PRIORITY Calc;
        end
    end

    // State: PRIORITY Calc
    always @negedge rst_n or (!rst_n & current_state == PRIORITY Calc) begin
        // Calculate effective priority
        effective_priority = max_priority;
        for (int i = 0; i < 10; i++) begin
            if (wait_counters[i] > STARVATION_THRESHOLD) begin
                effective_priority[i] = max_priority[i] + 1;
            end
        end

        // Apply priority override if enabled
        if (priority_override_en) begin
            effective_priority = (priority_override << 2) | (priority_override_en ? 0 : max_priority);
        end

        // Select highest priority interrupt
        next_interrupt_id = 0;
        for (int i = 0; i < 10; i++) begin
            if (effective_priority[i] > effective_priority[next_interrupt_id]) begin
                next_interrupt_id = i;
            end
        end

        current_state = SERVICE_PREP;
        next_state = next_state;
    end

    // State: SERVICE_PREP
    always @negedge rst_n or (!rst_n & current_state == SERVICE_PREP) begin
        // Prepare to service interrupt
        service_timer = 0;
        next_state = SERVICING;
    end

    // State: SERVICING
    always @negedge rst_n or (!rst_n & current_state == SERVICING) begin
        // Service the interrupt
        service_timer = service_timer + 1;
        next_state = COMPLETION;
    end

    // State: COMPLETION
    always @negedge rst_n or (!rst_n & current_state == COMPLETION) begin
        // Reset state and clear status
        current_state = IDLE;
        next_state = IDLE;
    end

    // Error handling
    always @negedge rst_n or (!rst_n & current_state == ERROR) begin
        // Set error flag
        timeout_error = 1;
    end

    // Mask handling
    always @negedge rst_n or (!rst_n & current_state == IDLE) begin
        active_mask = interrupt_mask;
    end

    // Update missed interrupts
    always @negedge rst_n or (!rst_n & current_state == IDLE) begin
        for (int i = 0; i < 10; i++) begin
            if (active_mask & (1 << i)) begin
                missed_interrupts[i] = missed_interrupts[i] + 1;
            end
        end
    end

    // Update wait counters
    always @negedge rst_n or (!rst_n & current_state == IDLE) begin
        for (int i = 0; i < 10; i++) begin
            if (!active_mask & (1 << i)) begin
                wait_counters[i] = 0;
            end
        end
    end

    // Update pending interrupts
    always @negedge rst_n or (!rst_n & current_state == IDLE) begin
        pending_interrupts = 0;
    end