module cvdp_copilot_bus_arbiter (
    input  logic reset,
    input  logic clk,
    input  logic req1,
    input  logic req2,
    input  logic dynamic_priority,  // Determines priority when both req1 and req2 are active.
    output reg  grant1,
    output reg  grant2
);

  // State Encoding
  localparam IDLE  = 3'b000,
             GRANT1 = 3'b001,
             GRANT2 = 3'b010;

  // STATE REGISTERS
  reg [2:0] state, next_state;

  // State Transition (synchronous to clk with reset)
  always @(posedge clk or posedge reset) begin
    if (reset)
      state <= IDLE;
    else
      state <= next_state;
  end

  // Next State Logic
  // Note: When both req1 and req2 are active, the arbiter uses dynamic_priority to decide
  // which master gets granted. To avoid glitches from rapid toggling of dynamic_priority,
  // it is assumed that dynamic_priority is stable for one clock cycle.
  always @(*) begin
    // Default: hold current state
    next_state = state;
    
    // Determine next state based on request signals and dynamic priority
    if (req1 && req2) begin
      // Both requests asserted: use dynamic_priority to decide.
      next_state = (dynamic_priority ? GRANT1 : GRANT2);
    end else if (req1) begin
      next_state = GRANT1;
    end else if (req2) begin
      next_state = GRANT2;
    end else begin
      next_state = IDLE;
    end
  end

  // Output Logic
  // One-cycle latency: grants are updated based on the current state.
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      grant1 <= 1'b0;
      grant2 <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          grant1 <= 1'b0;
          grant2 <= 1'b0;
        end
        GRANT1: begin
          grant1 <= 1'b1;
          grant2 <= 1'b0;
        end
        GRANT2: begin
          grant1 <= 1'b0;
          grant2 <= 1'b1;
        end
        default: begin
          grant1 <= 1'b0;
          grant2 <= 1'b0;
        end
      endcase
    end
  end

endmodule