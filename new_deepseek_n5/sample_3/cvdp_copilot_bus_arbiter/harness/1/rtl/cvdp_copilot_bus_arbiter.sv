module bus_arbiter (
    input wire reset,
    input wire clk,
    input wire req1,
    input wire req2,
    output reg grant1,
    output reg grant2
);
    // State encoding using localparam
    localparam IDLE    = 3'b000,
               GRANT_1 = 3'b001,
               GRANT_2 = 3'b010,
               CLEAR   = 3'b011;

    // State registers
    reg [2:0] state;
    reg [2:0] next_state;

    // Sequential logic for state transition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Combinational logic for next state
    always @(*) begin
        // Default assignments
        next_state = state;

        case (state)
            GRANT_2: 
                if (req2 && !req1)
                    next_state = GRANT_2;
                else
                    next_state = IDLE;
            GRANT_1: 
                if (req1 && !req2)
                    next_state = GRANT_1;
                else
                    next_state = IDLE;
            IDLE: 
                if (req1 && req2)
                    next_state = GRANT_2;
                else if (req1)
                    next_state = GRANT_1;
                else
                    next_state = IDLE;
            CLEAR: 
                next_state = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            case (next_state)
                GRANT_1: grant1 <= 1'b1; grant2 <= 1'b0;
                GRANT_2: grant1 <= 1'b0; grant2 <= 1'b1;
                IDLE:   grant1 <= 1'b0; grant2 <= 1'b0;
                CLEAR:  grant1 <= 1'b0; grant2 <= 1'b0;
            endcase
        end
    end

endmodule