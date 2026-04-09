module cvdp_copilot_bus_arbiter (
    input  reset,
    input  clk,
    input  req1,
    input  req2,
    input  dynamic_priority, // 1 = req1 has priority, 0 = req2 has priority when both reqs are active
    output reg grant1,
    output reg grant2
);

  // State Encoding
  // States:
  //   IDLE       : No requests asserted.
  //   GRANT_1    : Only req1 is active.
  //   GRANT_2    : Only req2 is active.
  //   DYNAMIC    : Both req1 and req2 are active; decision based on dynamic_priority.
  localparam IDLE    = 3'b000,
             GRANT_1 = 3'b001,
             GRANT_2 = 3'b010,
             DYNAMIC = 3'b011;

  // STATE REGISTERS
  reg [2:0] state;      // Current state
  reg [2:0] next_state; // Next state

  // State Register: Synchronous reset and clocked state update.
  always @(posedge clk or posedge reset)
  begin
    if (reset)
      state <= IDLE;
    else
      state <= next_state;
  end

  // Next State Logic
  // FSM transitions based on req1, req2, and dynamic_priority.
  // Note: dynamic_priority is assumed to change no faster than one clock cycle to avoid glitches.
  always @(*) begin
    next_state = state; // Default assignment
    case (state)
      IDLE: begin
        if (!req1 && !req2)
          next_state = IDLE;
        else if (req1 && !req2)
          next_state = GRANT_1;
        else if (!req1 && req2)
          next_state = GRANT_2;
        else if (req1 && req2)
          next_state = DYNAMIC; // Both requests active: defer decision to next cycle.
      end
      GRANT_1: begin
        // If both requests become active, transition to DYNAMIC.
        if (req1 && req2)
          next_state = DYNAMIC;
        // If only req1 remains active, stay in GRANT_1.
        else if (req1)
          next_state = GRANT_1;
        // If req1 deasserts and req2 is active, switch to GRANT_2.
        else if (req2)
          next_state = GRANT_2;
        // If no request is active, return to IDLE.
        else
          next_state = IDLE;
      end
      GRANT_2: begin
        // If both requests become active, transition to DYNAMIC.
        if (req1 && req2)
          next_state = DYNAMIC;
        // If only req2 remains active, stay in GRANT_2.
        else if (req2)
          next_state = GRANT_2;
        // If req2 deasserts and req1 is active, switch to GRANT_1.
        else if (req1)
          next_state = GRANT_1;
        // If no request is active, return to IDLE.
        else
          next_state = IDLE;
      end
      DYNAMIC: begin
        // In DYNAMIC state, both requests are active.
        // If one request deasserts, handle as single request.
        if (req1 && !req2)
          next_state = GRANT_1;
        else if (!req1 && req2)
          next_state = GRANT_2;
        // If both remain active, decide based on dynamic_priority.
        else if (req1 && req2)
          next_state = (dynamic_priority) ? GRANT_1 : GRANT_2;
        // If neither request is active, return to IDLE.
        else
          next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  // Output Logic
  // Grant signals are updated based on the next state to ensure one-cycle latency.
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      grant1 <= 1'b0;
      grant2 <= 1'b0;
    end else begin
      case (next_state)
        IDLE: begin
          grant1 <= 1'b0;
          grant2 <= 1'b0;
        end
        GRANT_1: begin
          grant1 <= 1'b1;
          grant2 <= 1'b0;
        end
        GRANT_2: begin
          grant1 <= 1'b0;
          grant2 <= 1'b1;
        end
        DYNAMIC: begin
          // No grant is asserted in the DYNAMIC state.
          grant1 <= 1'b0;
          grant2 <= 1'b0;
        end
        default: begin
          grant1 <= 1'b0;
          grant2 <= 1'b0;
        end
      endcase
    end
  end

endmodule