module cvdp_copilot_bus_arbiter (
    input reset,
    input clk,
    input req1,
    input req2,
    output reg grant1,
    output reg grant2
);

    localparam IDLE = 3'b000,
                   GRANT_1 = 3'b001,
                   GRANT_2 = 3'b010,
                   MASTER1_PRI = 3'b011,
                   CLEAR = 3'b100;

    reg [2:0] state;
    reg [2:0] next_state;
    wire dynamic_priority; // Assume it's an input

    initial begin
        state = IDLE;
        next_state = IDLE;
        grant1 = 1'b0;
        grant2 = 1'b0;
    end

    always @(posedge clk or posedge reset or dynamic_priority) begin
        if (reset) begin
            state <= IDLE;
            next_state <= IDLE;
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    // Next State Logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (req2)
                    next_state = GRANT_2;
                else if (req1)
                    next_state = GRANT_1;
            end
            GRANT_2: begin
                if (!req2 && !req1)
                    next_state = IDLE;
                else if (!req2 && req1)
                    next_state = GRANT_1;
            end
            GRANT_1: begin
                if (!req1 && !req2)
                    next_state = IDLE;
                else if (req2)
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
