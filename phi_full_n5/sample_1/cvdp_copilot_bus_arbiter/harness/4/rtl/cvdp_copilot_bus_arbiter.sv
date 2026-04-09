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
localparam IDLE        = 3'b000,
            GRANT_1     = 3'b001,
            GRANT_2     = 3'b010,
            MASTER1_PRI = 3'b011,
            CLEAR       = 3'b100;

// State Registries
reg [2:0] state;      // Current state
reg [2:0] next_state; // Next state

// State Transition
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

// Next State Logic
always @(*) begin
    next_state = state; // Default assignment
    case (state)
        IDLE: begin
            if (req2 && dynamic_priority)
                next_state = GRANT_2;
            else if (req1 && !dynamic_priority)
                next_state = GRANT_1;
        end
        GRANT_1: begin
            if (!req1 && !req2 && !dynamic_priority)
                next_state = IDLE; // Both requests deasserted and no priority
            else if (!req1 && req2 && dynamic_priority)
                next_state = GRANT_2; // Grant Master 2 based on priority
        end
        GRANT_2: begin
            if (!req2 && !req1 && dynamic_priority)
                next_state = GRANT_2; // Grant Master 2 based on priority
            else if (req2 && !dynamic_priority)
                next_state = IDLE; // Grant Master 1, transition to IDLE
        end
        MASTER1_PRI: begin
            if (req2 && !dynamic_priority)
                next_state = IDLE; // Grant Master 2, transition to IDLE
            else if (req1 && dynamic_priority)
                next_state = GRANT_1; // Grant Master 1 based on priority
        end
        CLEAR: begin
            if (req2 && dynamic_priority)
                next_state = GRANT_2;
            else if (req1 && !dynamic_priority)
                next_state = IDLE; // Default to IDLE if no requests and no priority
        end
        default: next_state = IDLE;
    endcase
end

// Output Logic
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
            MASTER1_PRI: begin
                grant1 <= 1'b0; // During this state, neither master is granted
                grant2 <= 1'b0;
            end
            CLEAR: begin
                grant1 <= 1'b0;
                grant2 <= 1'b0;
            end
        endcase
    end
end

endmodule
