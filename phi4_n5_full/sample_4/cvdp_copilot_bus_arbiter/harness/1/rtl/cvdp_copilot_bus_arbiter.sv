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
            IDLE: begin
                if (req2)
                    next_state = GRANT_2;
                else if (req1)
                    next_state = GRANT_1;
                else
                    next_state = IDLE;
            end

            GRANT_1: begin
                // If req2 becomes active, prioritize it
                if (req2)
                    next_state = GRANT_2;
                // If req1 deasserts, clear the grant
                else if (!req1)
                    next_state = CLEAR;
                else
                    next_state = GRANT_1;
            end

            GRANT_2: begin
                // If req2 deasserts, go to CLEAR
                if (!req2)
                    next_state = CLEAR;
                else
                    next_state = GRANT_2;
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

    // Output logic: drive grants based on next_state
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            case (next_state)
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