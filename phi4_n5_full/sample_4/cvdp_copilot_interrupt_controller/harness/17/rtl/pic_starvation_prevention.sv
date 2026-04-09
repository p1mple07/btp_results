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

  // Parameters for thresholds
  parameter STARVATION_THRESHOLD = 5;
  parameter SERVICE_TIMEOUT      = 10;

  // State encoding
  localparam [2:0]
    IDLE       = 3'b000,
    PRIORITY_CALC = 3'b001,
    SERVICE_PREP  = 3'b010,
    SERVICING     = 3'b011,
    COMPLETION    = 3'b100,
    ERROR         = 3'b111;

  // State registers and internal registers
  reg [2:0] current_state, next_state;
  reg [9:0] pending_interrupts;
  reg [3:0] wait_counters [0:9];
  reg [4:0] effective_priority [0:9];
  reg [3:0] service_timer;
  reg        timeout_error;
  reg [3:0] next_interrupt_id;
  reg [4:0] max_priority;

  // Sequential block for state update and register updates
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state         <= IDLE;
      pending_interrupts    <= 10'b0;
      interrupt_status      <= 10'b0;
      missed_interrupts     <= 10'b0;
      starvation_detected   <= 1'b0;
      service_timer         <= 4'd0;
      timeout_error         <= 1'b0;
      next_interrupt_id     <= 4'd0;
      max_priority          <= 5'd0;
      interrupt_valid       <= 1'b0;
      interrupt_id          <= 4'd0;
      // Reset all wait counters and effective priorities
      integer i;
      for (i = 0; i < 10; i = i + 1) begin
        wait_counters[i]        <= 4'd0;
        effective_priority[i]   <= 5'd0;
      end
    end
    else begin
      current_state <= next_state;
      case (current_state)
        IDLE: begin
          // On reset_interrupts, clear internal registers
          if (reset_interrupts) begin
            pending_interrupts    <= 10'b0;
            interrupt_status      <= 10'b0;
            missed_interrupts     <= 10'b0;
            starvation_detected   <= 1'b0;
            service_timer         <= 4'd0;
            timeout_error         <= 1'b0;
            next_interrupt_id     <= 4'd0;
            max_priority          <= 5'd0;
            interrupt_valid       <= 1'b0;
            interrupt_id          <= 4'd0;
            integer j;
            for (j = 0; j < 10; j = j + 1) begin
              wait_counters[j]        <= 4'd0;
              effective_priority[j]   <= 5'd0;
            end
          end
        end
        PRIORITY_CALC: begin
          // Update wait counters for each pending interrupt
          integer k;
          for (k = 0; k < 10; k = k + 1) begin
            if (pending_interrupts[k])
              wait_counters[k] <= wait_counters[k] + 1;
            else
              wait_counters[k] <= 4'd0;
          end
          // Compute effective priorities for pending interrupts.
          // Base priority assumed as the interrupt index (k) plus dynamic wait counter.
          // Priority override is applied if enabled for the specific interrupt.
          for (k = 0; k < 10; k = k + 1) begin
            if (pending_interrupts[k]) begin
              if (priority_override_en && (k == override_interrupt_id))
                effective_priority[k] <= priority_override;
              else
                effective_priority[k] <= {1'b0, k} + wait_counters[k];
            end
            else begin
              effective_priority[k] <= 5'd0;
            end
          end
          // Detect starvation: if any wait counter exceeds threshold, assert starvation_detected.
          starvation_detected <= 1'b0;
          for (k = 0; k < 10; k = k + 1) begin
            if (wait_counters[k] >= STARVATION_THRESHOLD)
              starvation_detected <= 1'b1;
          end
          // Select the pending interrupt with the maximum effective priority.
          max_priority    <= 5'd0;
          next_interrupt_id <= 4'd0;
          for (k = 0; k < 10; k = k + 1) begin
            if (pending_interrupts[k]) begin
              if (effective_priority[k] > max_priority) begin
                max_priority        <= effective_priority[k];
                next_interrupt_id   <= k;
              end
            end
          end
        end
        SERVICE_PREP: begin
          // Prepare to service the selected interrupt.
          interrupt_valid <= 1'b1;
          interrupt_id    <= next_interrupt_id;
          // Set the corresponding bit in interrupt_status.
          interrupt_status[next_interrupt_id] <= 1'b1;
          service_timer   <= 4'd0;
        end
        SERVICING: begin
          service_timer <= service_timer + 1;
          if (service_timer >= SERVICE_TIMEOUT)
            timeout_error <= 1'b1;
          // If the system acknowledges the interrupt, proceed to completion.
          if (interrupt_ack) begin
            timeout_error <= 1'b0;
            next_state    <= COMPLETION;
          end
        end
        COMPLETION: begin
          // Clear the serviced interrupt from pending registers.
          pending_interrupts[next_interrupt_id] <= 1'b0;
          wait_counters[next_interrupt_id]       <= 4'd0;
          effective_priority[next_interrupt_id]  <= 5'd0;
          // Clear the interrupt status bit.
          interrupt_status[next_interrupt_id]    <= 1'b0;
          next_state                             <= IDLE;
        end
        ERROR: begin
          // In case of error, clear the error flag and return to IDLE.
          timeout_error <= 1'b0;
          next_state    <= IDLE;
        end
        default: begin
          next_state <= IDLE;
        end
      endcase
    end
  end

  // Next state combinational logic
  always @(*) begin
    next_state = current_state;
    case (current_state)
      IDLE: begin
        // Transition to priority calculation if there are pending interrupts.
        if (pending_interrupts != 10'b0)
          next_state = PRIORITY_CALC;
      end
      PRIORITY_CALC: begin
        next_state = SERVICE_PREP;
      end
      SERVICE_PREP: begin
        next_state = SERVICING;
      end
      SERVICING: begin
        if (interrupt_ack)
          next_state = COMPLETION;
        else if (service_timer >= SERVICE_TIMEOUT)
          next_state = ERROR;
        else
          next_state = SERVICING;
      end
      COMPLETION: begin
        next_state = IDLE;
      end
      ERROR: begin
        next_state = IDLE;
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end

  // Update pending_interrupts and missed_interrupts on interrupt trigger.
  // If an interrupt is requested while masked, increment its missed count.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pending_interrupts <= 10'b0;
      missed_interrupts  <= 10'b0;
    end
    else if (interrupt_trig) begin
      integer i;
      for (i = 0; i < 10; i = i + 1) begin
        if (interrupt_requests[i]) begin
          if (interrupt_mask[i])
            missed_interrupts[i] <= missed_interrupts[i] + 1;
          else
            pending_interrupts[i] <= 1'b1;
        end
      end
    end
  end

endmodule