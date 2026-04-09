module cvdp_copilot_bus_arbiter (
    input  reset,
    input  clk,
    input  req1,
    input  req2,
    input  dynamic_priority,  // New control input for dynamic priority
    output reg grant1,
    output reg grant2
);

//---------------------------------------------------------------------
// State Encoding
//---------------------------------------------------------------------
// Using a reduced state set for clarity:
// IDLE     : No request is active.
// GRANT_1  : Master 1 is granted.
// GRANT_2  : Master 2 is granted.
localparam IDLE     = 3'b000,
           GRANT_1  = 3'b001,
           GRANT_2  = 3'b010;

//---------------------------------------------------------------------
// STATE REGISTERS
//---------------------------------------------------------------------
reg [2:0] state;      // Current state
reg [2:0] next_state; // Next state

//---------------------------------------------------------------------
// State Transition (Synchronous to clk, asynchronous reset)
//---------------------------------------------------------------------
always @(posedge clk or posedge reset)
begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

//---------------------------------------------------------------------
// Next State Logic with Dynamic Priority Feature
//
// Functional Requirements Handled:
// 1. In IDLE: if no request, remain IDLE; if a single request, grant that master;
//    if both requests active, use dynamic_priority to decide.
// 2. In GRANT_1: if req1 deasserts and req2 becomes active, switch to GRANT_2;
//    if req1 remains active, stay in GRANT_1; if req2 becomes active concurrently,
//    dynamic_priority determines whether to remain in GRANT_1 or switch to GRANT_2.
// 3. In GRANT_2: symmetric to GRANT_1.
// 4. One-cycle latency: the grant outputs follow next_state.
//---------------------------------------------------------------------
always @(*) begin
    next_state = state; // Default: maintain current state
    case (state)
        IDLE: begin
            if (req1 && req2) begin
                // Both requests active: dynamic_priority selects the grant.
                if (dynamic_priority)
                    next_state = GRANT_1;
                else
                    next_state = GRANT_2;
            end
            else if (req1)
                next_state = GRANT_1;
            else if (req2)
                next_state = GRANT_2;
            else
                next_state = IDLE;
        end
        GRANT_1: begin
            // Currently granting Master 1.
            if (!req1) begin
                // If req1 deasserts, check if req2 is active.
                if (req2)
                    next_state = GRANT_2; // Only req2 active -> grant Master 2.
                else
                    next_state = IDLE;
            end
            else begin
                // req1 remains active.
                if (req2) begin
                    // Both requests active while in GRANT_1: dynamic_priority decides.
                    if (dynamic_priority)
                        next_state = GRANT_1;
                    else
                        next_state = GRANT_2;
                end
                else
                    next_state = GRANT_1;
            end
        end
        GRANT_2: begin
            // Currently granting Master 2.
            if (!req2) begin
                if (req1)
                    next_state = GRANT_1;
                else
                    next_state = IDLE;
            end
            else begin
                if (req1) begin
                    // Both requests active while in GRANT_2: dynamic_priority decides.
                    if (dynamic_priority)
                        next_state = GRANT_1;
                    else
                        next_state = GRANT_2;
                end
                else
                    next_state = GRANT_2;
            end
        end
        default: next_state = IDLE;
    endcase
end

//---------------------------------------------------------------------
// Output Logic (One-cycle latency from request to grant)
//---------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
    if (reset) begin
        grant1 <= 1'b0;
        grant2 <= 1'b0;
    end
    else begin
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

endmodule