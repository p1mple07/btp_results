module bus_arbiter (
    input clk,
    input reset,
    input req1,
    input req2,
    input dynamic_priority,
    output reg grant1,
    output reg grant2
    );
  
    localparam IDLE        = 3'b000,
                  GRANT_1     = 3'b001,
                  GRANT_2     = 3'b010,
                  MASTER1_PRI = 3'b011,
                  CLEAR       = 3'b100;
    
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
                if (req2)
                    next_state = GRANT_2;
                else if (req1)
                    next_state = GRANT_1;
            end
            GRANT_2: begin
                if (!req2 &&!req1)
                    next_state = IDLE; // Both requests deasserted
                else if (!req2 && req1)
                    next_state = GRANT_1; // Switch to GRANT_1 if req1 is still asserted
            end
            GRANT_1: begin
                if (!req1 &&!req2)
                    next_state = IDLE; // Both requests deasserted
                else if (req2)
                    next_state = GRANT_2; // req2 has priority
            end
            MASTER1_PRI: begin
                if (req2)
                    next_state = GRANT_2; // Grant Master 2 if req2 is asserted
                else if (req1)
                    next_state = GRANT_1; // Grant Master 1 if only req1 is asserted
                else
                    next_state = IDLE; // No requests, transition to IDLE
            end
            CLEAR: begin
                if (req2)
                    next_state = GRANT_2;
                else if (req1)
                    next_state = GRANT_1;
                else
                    next_state = IDLE; // Default to IDLE if no requests
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
                    grant1 <= 1'b0;
                    grant2 <= 1'b0;
                end
                CLEAR: begin
                    grant1 <= 1'b0;
                    grant2 <= 1'b0;
                end
            endcase
        end
    endmodule