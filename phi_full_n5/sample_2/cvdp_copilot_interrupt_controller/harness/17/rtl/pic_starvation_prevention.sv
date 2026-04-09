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

    // Interrupt Requests
    always @(posedge clk) begin
        if (reset_interrupts) begin
            pending_interrupts <= 0;
            active_mask <= 0;
            wait_counters <= 0;
        end else if (interrupt_trig) begin
            pending_interrupts <= interrupt_requests;
            active_mask <= interrupt_mask;
        end
    end

    // Priority Calculation
    always @(posedge clk) begin
        if (current_state == IDLE) begin
            for (int i = 0; i < 10; i = i + 1) begin
                if (active_mask[i] && ~interrupt_status[i]) begin
                    wait_counters[i] <= 0;
                end else begin
                    wait_counters[i] <= wait_counters[i] + 1;
                end
            end
        end else if (current_state == PRIORITY_CALC) begin
            max_priority <= 5'b0;
            for (int i = 0; i < 10; i = i + 1) begin
                if (priority_override[i] && ~interrupt_status[i]) begin
                    effective_priority[i] <= priority_override[i];
                    max_priority <= max_priority + priority_override[i];
                end else if (wait_counters[i] > STARVATION_THRESHOLD) begin
                    effective_priority[i] <= 5'b1;
                    max_priority <= max_priority + 5'b1;
                end else begin
                    effective_priority[i] <= (active_mask[i] & interrupt_status[i]) ? 5'b0 : 5'b1;
                end
            end
            if (max_priority > 5'b7) begin
                next_interrupt_id <= override_interrupt_id;
                max_priority <= max_priority - 5'b7;
            end else begin
                next_interrupt_id <= 0;
            end
        end
    end

    // State Machine
    always @(posedge clk) begin
        current_state <= next_state;
        next_state <= IDLE;
        if (interrupt_ack) begin
            if (current_state == SERVICING) begin
                timeout_error <= 0;
                next_interrupt_id <= next_interrupt_id + 1;
            end
        end
    end

    // State Transitions
    always @(current_state) begin
        case (current_state)
            IDLE: begin
                next_state = PRIORITY_CALC;
            end
            PRIORITY_CALC: begin
                next_state = SERVICE_PREP;
            end
            SERVICE_PREP: begin
                if (next_interrupt_id != 0) begin
                    next_state = SERVICING;
                    interrupt_id <= next_interrupt_id;
                end else begin
                    next_state = IDLE;
                end
            end
            SERVICING: begin
                if (service_timer == 5'd1000) begin
                    timeout_error <= 1;
                    next_state = ERROR;
                end else begin
                    next_state = SERVICE_PREP;
                end
            end
            ERROR: begin
                next_state = IDLE;
            end
        endcase
    end

    // Interrupt Servicing
    always @(posedge clk) begin
        if (current_state == SERVICING) begin
            if (timeout_error) begin
                interrupt_valid <= 0;
                missed_interrupts <= interrupt_status;
                starvation_detected <= 1;
                next_state <= IDLE;
            end else begin
                interrupt_valid <= 1;
                interrupt_status <= active_mask;
                service_timer <= 5'd1000;
            end
        end
    end

    // Reset Behavior
    always @(posedge clk) begin
        if (rst_n) begin
            current_state <= IDLE;
            next_interrupt_id <= 0;
            max_priority <= 0;
            wait_counters <= 0;
            interrupt_status <= 0;
            active_mask <= 0;
        end
    end

endmodule
