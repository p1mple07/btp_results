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
            CLEAR       = 3'b100,
            PRIORITY    = 3'b101,
            UNKNOWN     = 3'b110;
  
// STATE REGISTERS
reg [2:0] state;      // Current state
reg [2:0] next_state; // Next state
reg priority_state;  // State for handling dynamic priority
  
// State Transition
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
    priority_state <= 0;
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
        GRANT_1: begin
            if (req2)
                next_state = GRANT_2;
            else if (req1)
                next_state = GRANT_1;
            else
                next_state = IDLE;
        end
        GRANT_2: begin
            if (req1)
                next_state = GRANT_1;
            else if (req2)
                next_state = GRANT_2;
            else
                next_state = IDLE;
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
        PRIORITY: begin
            if (dynamic_priority)
                next_state = GRANT_1;
            else
                next_state = GRANT_2;
            priority_state <= 1;
        end
        UNKNOWN: next_state = IDLE;
        default: next_state = IDLE;
    endcase
end

// Priority State Handling
always @(posedge clk) begin
    if (priority_state) begin
        if (dynamic_priority)
            grant1 <= 1'b1;
            grant2 <= 1'b0;
        else
            grant1 <= 1'b0;
            grant2 <= 1'b1;
        priority_state <= 0;
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
                grant2 <= 1'b0;
            end
            CLEAR: begin
                grant1 <= 1'b0;
                grant2 <= 1'b0;
            end
            PRIORITY: begin
                grant1 <= 1'b1;
                grant2 <= 1'b0;
            end
            UNKNOWN: begin
                grant1 <= 1'b0;
                grant2 <= 1'b1;
            end
        endcase
    end
end

endmodule