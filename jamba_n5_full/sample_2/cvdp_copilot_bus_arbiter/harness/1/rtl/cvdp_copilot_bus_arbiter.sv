module bus_arbiter (
    input wire reset,
    input wire clk,
    input wire req1,
    input wire req2,
    output reg grant1,
    output reg grant2
);

    localparam IDLE     = 3'b000,
                      GRANT_1  = 3'b001,
                      GRANT_2  = 3'b010,
                      CLEAR    = 3'b011;

    reg [2:0] state;
    reg [2:0] next_state;

    // Sequential state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Determine the next state based on current state and requests
    always @(*) begin
        next_state = state;

        case (state)
            IDLE:
                next_state = GRANT_2; // both masters present → priority to req2
                grant1 <= 1'b0;
                grant2 <= 1'b0;

            GRANT_1:
                next_state = GRANT_2;
                grant1 <= 1'b1;
                grant2 <= 1'b0;

            GRANT_2:
                next_state = CLEAR;
                grant1 <= 1'b0;
                grant2 <= 1'b0;

            CLEAR:
                next_state = IDLE;
                grant1 <= 1'b0;
                grant2 <= 1'b0;
        endcase
    end

    // Grant signals driven from the next state
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            if (next_state == GRANT_1) begin
                grant1 <= 1'b1;
            end else if (next_state == GRANT_2) begin
                grant2 <= 1'b1;
            end else if (next_state == CLEAR) begin
                grant1 <= 1'b0;
                grant2 <= 1'b0;
            end
        end
    end

endmodule
