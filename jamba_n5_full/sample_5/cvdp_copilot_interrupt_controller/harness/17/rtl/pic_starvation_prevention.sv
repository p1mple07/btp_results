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

    reg [2:0] current_state;
    reg [9:0] pending_interrupts;
    reg [3:0] wait_counters [0:9];
    reg [4:0] effective_priority [0:9];
    reg [9:0] active_mask;
    reg [3:0] service_timer;
    reg timeout_error;
    reg [3:0] next_interrupt_id;
    reg [4:0] max_priority;

    always @(posedge clk or posedge reset_interrupts) begin
        if (rst_n) begin
            current_state <= IDLE;
            pending_interrupts <= 0;
            wait_counters[0:9] = 0;
            effective_priority[0:9] = 0;
            active_mask <= 0;
            service_timer <= 0;
            timeout_error <= 0;
            next_interrupt_id <= 0;
            max_priority <= 0;
            interrupt_id <= 0;
            interrupt_valid <= 0;
            interrupt_status <= 0;
            missed_interrupts <= 0;
            starvation_detected <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    next_state = PRIORITY_CALC;
                end

                PRIORITY_CALC: begin
                    next_state = SERVICE_PREP;
                end

                SERVICE_PREP: begin
                    next_state = SERVICING;
                end

                SERVICING: begin
                    // handle timeout
                    timeout_error <= false;
                    if (timeout_error) begin
                        next_state = COMPLETION;
                    end else if (interrupt_valid) begin
                        next_state = COMPLETION;
                    end else begin
                        next_state = SERVICING;
                    end
                end

                COMPLETION: begin
                    interrupt_valid <= 0;
                    next_state = IDLE;
                end

                ERROR: begin
                    next_state = COMPLETION;
                end

                default: next_state = IDLE;
            endcase
        end
    end

endmodule
