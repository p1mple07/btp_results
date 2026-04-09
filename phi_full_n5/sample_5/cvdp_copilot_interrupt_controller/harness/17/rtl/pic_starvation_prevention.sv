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

    // Interrupts Arbitration Logic
    always @(posedge clk) begin
        if (reset_interrupts) begin
            current_state <= IDLE;
            pending_interrupts <= 0;
            active_mask <= 0;
            wait_counters <= 0;
            effective_priority <= 0;
            next_interrupt_id <= 0;
            timeout_error <= 0;
            max_priority <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (interrupt_trig) begin
                        next_state <= PRIORITY_CALC;
                    end else next_state <= IDLE;
                end
                PRIORITY_CALC: begin
                    if (priority_override_en) begin
                        max_priority = priority_override;
                        next_interrupt_id = override_interrupt_id;
                    end else begin
                        max_priority = interrupt_requests & ~interrupt_mask;
                        next_interrupt_id = max_priority > 0;
                    end
                    next_state <= SERVICE_PREP;
                end
                SERVICE_PREP: begin
                    if (next_interrupt_id) begin
                        interrupt_id <= next_interrupt_id;
                        interrupt_valid <= 1;
                        current_state <= SERVICING;
                        active_mask <= interrupt_mask[next_interrupt_id];
                        wait_counters[next_interrupt_id] <= 0;
                        max_priority <= max_priority[next_interrupt_id];
                    end else next_state <= IDLE;
                end
                SERVICING: begin
                    if (active_mask) begin
                        service_timer <= 0;
                        next_state <= COMPLETION;
                    end else begin
                        service_timer <= service_timer + 1;
                        if (service_timer > STARVATION_THRESHOLD) begin
                            starvation_detected <= 1;
                        end
                        next_state <= SERVICE_PREP;
                    end
                end
                COMPLETION: begin
                    interrupt_status <= interrupt_status & active_mask;
                    missed_interrupts <= missed_interrupts | active_mask;
                    timeout_error <= 0;
                    current_state <= IDLE;
                end
                ERROR: begin
                    timeout_error <= 1;
                    current_state <= IDLE;
                end
            endcase
        end
    end

    // Interrupt Status Update Logic
    always @(posedge clk) begin
        if (reset_interrupts) begin
            interrupt_status <= 0;
        end else begin
            interrupt_status <= interrupt_status | (active_mask & pending_interrupts);
        end
    end

    // Masked Interrupts and Missed Interrupts Handling
    always @(posedge clk) begin
        if (reset_interrupts) begin
            missed_interrupts <= 0;
        end else begin
            missed_interrupts <= missed_interrupts | (pending_interrupts & ~active_mask);
        end
    end

endmodule
