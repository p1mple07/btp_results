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
        case (state)
            IDLE: begin
                next_state = GRANT_2;
            end

            GRANT_1: begin
                next_state = GRANT_2;
            end

            GRANT_2: begin
                next_state = CLEAR;
            end

            CLEAR: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(state) begin
        if (next_state == GRANT_2) begin
            grant1 <= 1'b0;
            grant2 <= 1'b1;
        end else if (next_state == CLEAR) begin
            grant1 <= 1'b1;
            grant2 <= 1'b0;
        end else if (next_state == IDLE) begin
            grant1 <= 1'b1;
            grant2 <= 1'b0;
        end else if (next_state == GRANT_1) begin
            grant1 <= 1'b1;
            grant2 <= 1'b0;
        end
    end

endmodule
