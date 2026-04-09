module bus_arbiter (
    input wire reset,
    input wire clk,
    input wire req1,
    input wire req2,
    output reg grant1,
    output reg grant2
);

    localparam IDLE    = 3'b000,
                   GRANT_1 = 3'b001,
                   GRANT_2 = 3'b010,
                   CLEAR   = 3'b011;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE:
                if (req1) next_state = GRANT_1;
                else if (req2) next_state = GRANT_2;
                else next_state = IDLE;
            GRANT_1:
                if (req1) next_state = CLEAR;
                else next_state = IDLE;
            GRANT_2:
                if (req2) next_state = CLEAR;
                else next_state = IDLE;
            CLEAR:
                next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            if (next_state == GRANT_1) grant1 = 1'b1;
            else if (next_state == GRANT_2) grant2 = 1'b1;
            else grant1 <= 1'b0; grant2 <= 1'b0;
        end
    end

endmodule
