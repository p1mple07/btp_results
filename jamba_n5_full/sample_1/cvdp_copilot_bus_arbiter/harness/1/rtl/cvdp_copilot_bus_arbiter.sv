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
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                next_state = GRANT_1;
            end

            GRANT_1: begin
                next_state = GRANT_2;
                grant1 = 1'b0;
                grant2 = 1'b1;
            end

            GRANT_2: begin
                next_state = CLEAR;
                grant1 = 1'b0;
                grant2 = 1'b0;
            end

            CLEAR: begin
                next_state = IDLE;
                grant1 = 1'b0;
                grant2 = 1'b0;
            end

        endcase
    endelse

    always @(next_state) begin
        case (next_state)
            GRANT_1: begin
                if (~req1) grant1 = 1'b1;
                else grant1 = 1'b0;
                grant2 = 1'b0;
            end

            GRANT_2: begin
                if (~req2) grant1 = 1'b1;
                else grant1 = 1'b0;
                grant2 = 1'b0;
            end

            CLEAR: begin
                grant1 = 1'b0;
                grant2 = 1'b0;
            end

            default: grant1 = 1'b0; grant2 = 1'b0;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end
    end

endmodule
