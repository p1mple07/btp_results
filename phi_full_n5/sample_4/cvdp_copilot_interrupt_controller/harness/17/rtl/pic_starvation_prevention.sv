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

    // Priority calculation logic
    always @(posedge clk) begin
        if (reset_interrupts) begin
            current_state <= IDLE;
            pending_interrupts <= 0;
            wait_counters <= 0;
            effective_priority <= 0;
            max_priority <= 0;
            interrupt_id <= 4'b0000;
            interrupt_valid <= 0;
            active_mask <= 0;
            timeout_error <= 0;
        end else begin
            // Calculate effective priority
            for (int i = 0; i < 10; i = i + 1) begin
                effective_priority[i] <= (interrupt_requests[i] | (priority_override == override_interrupt_id[i] ? priority_override : 0));
                wait_counters[i] <= (interrupt_status[i] & ~active_mask[i]);
                if (wait_counters[i] >= STARVATION_THRESHOLD) begin
                    effective_priority[i] <= max_priority + 1;
                end
            end

            // Determine next interrupt
            max_priority <= max_priority + 1;
            next_interrupt_id <= (max_priority == effective_priority);

            // State machine logic
            case (current_state)
                IDLE: begin
                    if (interrupt_trig) begin
                        current_state <= PRIORITY_CALC;
                        interrupt_id <= next_interrupt_id;
                    end
                end
                PRIORITY_CALC: begin
                    if (priority_override_en && priority_override != 0) begin
                        max_priority <= max_priority + 1;
                        next_interrupt_id <= priority_override;
                        interrupt_id <= next_interrupt_id;
                    end
                    current_state <= SERVICE_PREP;
                end
                SERVICE_PREP: begin
                    if (interrupt_ack) begin
                        current_state <= SERVICING;
                        interrupt_valid <= 1;
                        interrupt_status <= active_mask;
                        service_timer <= 10'b0;
                    end
                end
                SERVICING: begin
                    if (service_timer == 10'd10) begin
                        current_state <= COMPLETION;
                        interrupt_id <= 4'b0000;
                        interrupt_status <= active_mask;
                        service_timer <= 10'b0;
                    end else begin
                        service_timer <= service_timer + 1;
                    end
                end
                COMPLETION: begin
                    current_state <= IDLE;
                    interrupt_id <= 4'b0000;
                    interrupt_valid <= 0;
                    active_mask <= 0;
                    timeout_error <= 0;
                end
                ERROR: begin
                    current_state <= IDLE;
                    interrupt_id <= 4'b0000;
                    interrupt_valid <= 0;
                    timeout_error <= 1;
                end
            endcase
        end
    end

    // Interrupt handling
    always @(posedge clk) begin
        if (reset_interrupts) begin
            interrupt_status <= 0;
            missed_interrupts <= 0;
        end else begin
            // Update interrupt status and missed interrupts
            if (interrupt_trig) begin
                interrupt_status <= interrupt_status | (interrupt_mask & interrupt_requests);
                missed_interrupts <= missed_interrupts | (interrupt_mask & ~interrupt_requests);
            end
        end
    end

    // Starvation detection
    always @(posedge clk) begin
        if (service_timer == 10'd10 && interrupt_valid == 0) begin
            starvation_detected <= 1;
        end else begin
            starvation_detected <= 0;
        end
    end

endmodule
