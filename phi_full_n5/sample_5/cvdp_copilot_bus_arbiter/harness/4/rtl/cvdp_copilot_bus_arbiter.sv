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

// FSM
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        grant1 <= 1'b0;
        grant2 <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (req1)
                    next_state = GRANT_1;
                else if (req2)
                    next_state = GRANT_2;
                else if (dynamic_priority)
                    next_state = MASTER1_PRI; // Dynamic priority takes precedence
                else
                    next_state = IDLE;
            end
            GRANT_1: begin
                if (!req1 && !req2 && !dynamic_priority)
                    next_state = IDLE;
                else if (dynamic_priority)
                    next_state = MASTER1_PRI;
                else
                    next_state = GRANT_1;
            end
            GRANT_2: begin
                if (!req2 && !req1 && !dynamic_priority)
                    next_state = IDLE;
                else if (dynamic_priority)
                    next_state = MASTER1_PRI;
                else
                    next_state = GRANT_2;
            end
            MASTER1_PRI: begin
                if (req2)
                    next_state = GRANT_2;
                else if (req1)
                    next_state = GRANT_1;
                else
                    next_state = IDLE;
            end
            CLEAR: begin
                if (req2)
                    next_state = GRANT_2;
                else if (req1)
                    next_state = GRANT_1;
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
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
                grant1 <= 1'b0;
                grant2 <= 1'b0; // During this state, neither master is granted
            end
            CLEAR: begin
                grant1 <= 1'b0;
                grant2 <= 1'b0;
            end
        endcase
    end
end

endmodule
