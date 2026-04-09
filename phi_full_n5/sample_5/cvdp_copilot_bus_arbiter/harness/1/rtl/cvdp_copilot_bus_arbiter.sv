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
                if (req1) begin
                    next_state = GRANT_1;
                end
                else if (req2) begin
                    next_state = GRANT_2;
                end
                else next_state = IDLE;
            end
            GRANT_1: begin
                if (!req1) begin
                    next_state = CLEAR;
                end
                else next_state = GRANT_1;
            end
            GRANT_2: begin
                if (!req2) begin
                    next_state = CLEAR;
                end
                else next_state = GRANT_2;
            end
            CLEAR: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            // Grant assignments based on next_state
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
                CLEAR: begin
                    grant1 <= 1'b0;
                    grant2 <= 1'b0;
                end
            endcase
        end
    end

endmodule
