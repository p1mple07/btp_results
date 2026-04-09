module cvdp_copilot_bus_arbiter (
    input reset,
    input clk,
    input req1,
    input req2,
    output reg grant1,
    output reg grant2
    );

    localparam IDLE        = 3'b000,
            GRANT_1       = 3'b001,
            GRANT_2       = 3'b010,
            MASTER1_PRI = 3'b011,
            CLEAR       = 3'b100;

    reg [2:0] state;      // Current state
    reg [2:0] next_state; // Next state
    reg [2:0] dynamic_priority; // Control signal

    // Always block for state transitions
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            next_state <= IDLE;
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    if (req1) next_state = GRANT_1;
                    else if (req2) next_state = GRANT_2;
                    else if (dynamic_priority == 1'b1) // high priority
                        next_state = GRANT_1;
                    else
                        next_state = GRANT_2;
                end
                GRANT_1: begin
                    if (!req1 && !req2) next_state = IDLE;
                    else if (req2) next_state = GRANT_2;
                    else next_state = GRANT_1;
                end
                GRANT_2: begin
                    if (!req2 && !req1) next_state = IDLE;
                    else if (req1) next_state = MASTER1_PRI;
                    else next_state = GRANT_2;
                end
                MASTER1_PRI: begin
                    if (req2) next_state = GRANT_2;
                    else if (req1) next_state = GRANT_1;
                    else next_state = IDLE;
                end
                CLEAR: begin
                    if (req2) next_state = GRANT_2;
                    else if (req1) next_state = GRANT_1;
                    else next_state = IDLE;
                end
            endcase
        end
    end

    // Assign grants based on next_state
    always @(*) begin
        grant1 <= (next_state == GRANT_1) ? 1'b1 : 1'b0;
        grant2 <= (next_state == GRANT_2) ? 1'b1 : 1'b0;
    end

endmodule
