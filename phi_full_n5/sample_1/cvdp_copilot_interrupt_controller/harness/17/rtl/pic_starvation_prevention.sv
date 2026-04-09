// SystemVerilog RTL for a Priority-Based Interrupt Controller with Starvation Prevention

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

    // State transition logic
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_state <= IDLE;
            service_timer <= 0;
            next_interrupt_id <= 0;
            max_priority <= 0;
            wait_counters <= 0;
            effective_priority <= 0;
        end else if (interrupt_trig) begin
            current_state <= PRIORITY_CALC;
        end else if (current_state == IDLE) begin
            if (interrupt_requests != 0) begin
                pending_interrupts <= interrupt_requests;
                next_interrupt_id <= 0;
                max_priority <= 0;
                service_timer <= 0;
                current_state <= SERVICE_PREP;
            end
        end else if (current_state == SERVICE_PREP) begin
            if (priority_override_en && override_interrupt_id != 0) begin
                max_priority <= priority_override;
                next_interrupt_id <= override_interrupt_id;
            end else if (priority_override_en == 0) begin
                max_priority <= effective_priority[interrupt_requests];
                next_interrupt_id <= interrupt_requests;
            end
            service_timer <= 0;
            current_state <= SERVICING;
        end else if (current_state == SERVICING) begin
            if (service_timer == STARVATION_THRESHOLD) begin
                starvation_detected <= 1;
                service_timer <= 0;
                current_state <= ERROR;
            end else begin
                service_timer <= service_timer + 1;
            end
        end else if (current_state == ERROR) begin
            interrupt_valid <= 0;
            next_interrupt_id <= 0;
            max_priority <= 0;
            service_timer <= 0;
            current_state <= IDLE;
        end
    end

    // Interrupt handling logic
    always @(posedge clk) begin
        if (reset_interrupts) begin
            pending_interrupts <= 0;
            missed_interrupts <= 0;
            active_mask <= 0;
            interrupt_status <= 0;
            interrupt_id <= 0;
        end else if (interrupt_ack) begin
            interrupt_status <= interrupt_status << 1;
            interrupt_id <= next_interrupt_id;
            service_timer <= 0;
            active_mask <= active_mask << 1;
            missed_interrupts <= missed_interrupts << 1;
            next_interrupt_id <= 0;
            max_priority <= 0;
            current_state <= IDLE;
        end
    end

    // Priority calculation logic
    always @(posedge clk) begin
        if (current_state == PRIORITY_CALC) begin
            effective_priority <= priority_override * (1 << interrupt_requests);
            if (active_mask[interrupt_requests] == 0) begin
                wait_counters[interrupt_requests] <= wait_counters[interrupt_requests] + 1;
            end
            if (wait_counters[interrupt_requests] > STARVATION_THRESHOLD) begin
                max_priority <= max_priority + (1 << interrupt_requests);
            end
        end
    end

    // Interrupt servicing logic
    always @(posedge clk) begin
        if (current_state == SERVICING) begin
            if (active_mask[interrupt_id] == 0) begin
                interrupt_status[interrupt_id] <= interrupt_status[interrupt_id] + 1;
                active_mask[interrupt_id] <= 1;
                service_timer <= STARVATION_THRESHOLD;
            end else if (service_timer == STARVATION_THRESHOLD) begin
                interrupt_status[interrupt_id] <= 0;
                missed_interrupts[interrupt_id] <= missed_interrupts[interrupt_id] + 1;
                service_timer <= 0;
                current_state <= IDLE;
            end
        end
    end

endmodule
