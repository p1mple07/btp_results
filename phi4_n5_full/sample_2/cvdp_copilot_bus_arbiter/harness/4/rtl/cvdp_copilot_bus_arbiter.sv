module cvdp_copilot_bus_arbiter (
    input reset,
    input clk,
    input req1,
    input req2,
    input dynamic_priority,
    output reg grant1,
    output reg grant2
);

// State Encoding
// Only three states are used: IDLE, GRANT_1, and GRANT_2.
localparam IDLE    = 3'b000,
           GRANT_1 = 3'b001,
           GRANT_2 = 3'b010;

// STATE REGISTERS
reg [2:0] state;      // Current state
reg [2:0] next_state; // Next state

// State Transition: synchronous reset sets state to IDLE.
always @(posedge clk or posedge reset)
begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

// Next State Logic: Determines the next state based on current state and inputs.
// Note: When both req1 and req2 are active, dynamic_priority controls which grant is issued.
always @(*) begin
    next_state = state; // Default assignment to hold state
    case (state)
        IDLE: begin
            if (req1 && !req2)
                next_state = GRANT_1;    // Only req1 active
            else if (req2 && !req1)
                next_state = GRANT_2;    // Only req2 active
            else if (req1 && req2)
                next_state = (dynamic_priority) ? GRANT_1 : GRANT_2; // Both active: priority controlled by dynamic_priority
            else
                next_state = IDLE;
        end
        GRANT_1: begin
            // If req1 deasserts while req2 is active, treat as a single request for req2.
            if (!req1 && req2)
                next_state = GRANT_2;
            // If both requests deassert, return to IDLE.
            else if (!req1 && !req2)
                next_state = IDLE;
            // If both remain active, choose based on dynamic_priority.
            else if (req1 && req2)
                next_state = (dynamic_priority) ? GRANT_1 : GRANT_2;
            else
                next_state = GRANT_1;
        end
        GRANT_2: begin
            // If req2 deasserts while req1 is active, treat as a single request for req1.
            if (!req2 && req1)
                next_state = GRANT_1;
            // If both requests deassert, return to IDLE.
            else if (!req2 && !req1)
                next_state = IDLE;
            // If both remain active, choose based on dynamic_priority.
            else if (req1 && req2)
                next_state = (dynamic_priority) ? GRANT_1 : GRANT_2;
            else
                next_state = GRANT_2;
        end
        default: next_state = IDLE;
    endcase
end

// Output Logic: One-cycle latency from request to grant.
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
            default: begin
                grant1 <= 1'b0;
                grant2 <= 1'b0;
            end
        endcase
    end
end

// Note: dynamic_priority is assumed to be synchronized to clk and must not toggle more than once per clock cycle to avoid glitches.

endmodule