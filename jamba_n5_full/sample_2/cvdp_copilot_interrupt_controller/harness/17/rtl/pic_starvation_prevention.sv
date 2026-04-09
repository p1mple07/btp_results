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

    localparam [2:0] IDLE = 3'b000,
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

    // Initial state
    always @(posedge clk or posedge reset_interrupts) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else if (current_state == IDLE) begin
            // Read interrupts and mask
            for (int i = 0; i < 10; i++) begin
                if (interrupt_requests[i]) begin
                    pending_interrupts[i] = 1'b1;
                end
            end
            next_state = PRIORITY_CALC;
        end else if (current_state == PRIORITY_CALC) begin
            // Compute effective priority
            for (int i = 0; i < 10; i++) begin
                effective_priority[i] = (interrupt_mask[i] && active_mask[i]) ? 
                                       ((priority_override_en & (1'b1 - priority_override)) ? 4'd31 : 4'd30) : 4'd30;
            end
            next_state = SERVICE_PREP;
        end else if (current_state == SERVICE_PREP) begin
            // Service the interrupt
            for (int i = 0; i < 10; i++) begin
                if (pending_interrupts[i]) begin
                    active_mask[i] = 1'b1;
                    service_timer = 5'd1; // arbitrary time
                end else
                    active_mask[i] = 1'b0;
                // Check timeout
                if (service_timer > 5'd10) begin
                    timeout_error = 1;
                end
            end
            next_state = SERVICING;
        end else if (current_state == SERVICING) begin
            // Handle timeout
            if (timeout_error) begin
                // Clear the interrupt
                for (int i = 0; i < 10; i++) begin
                    if (active_mask[i]) begin
                        active_mask[i] = 1'b0;
                    end
                end
                pending_interrupts <= {1'b0};
                next_state = COMPLETION;
            end else begin
                // Continue
                next_state = COMPLETION;
            end
        end else if (current_state == COMPLETION) begin
            // Clear the serviced interrupt
            for (int i = 0; i < 10; i++) begin
                if (active_mask[i]) begin
                    active_mask[i] = 1'b0;
                end
            end
            pending_interrupts <= {1'b0};
            next_state = IDLE;
        end else if (current_state == ERROR) begin
            // Error handled
            next_state = IDLE;
        end
    end

endmodule
