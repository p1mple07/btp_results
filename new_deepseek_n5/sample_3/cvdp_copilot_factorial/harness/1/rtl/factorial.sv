module factorial(
    input clock,
    input arst_n,
    input [4:0] num_in,
    input start,
    output [63:0] fact,
    output busy,
    output done
);

    // FSM state
    reg state = IDLE;
    reg [4:0] counter = 0;

    // State transitions
    always @(posedge clock or negedge arst_n) begin
        if (start & num_in) begin
            if (state == IDLE) begin
                state = BUSY;
                busy = 1;
                done = 0;
            end else if (state == BUSY) begin
                counter = num_in;
                busy = 1;
                done = 0;
            end else if (state == DONE) begin
                busy = 0;
                done = 1;
            end
        end
    end

    // Factorial computation
    always @(posedge clock) begin
        if (state == BUSY) begin
            if (counter > 0) begin
                fact = fact + num_in;
                counter = counter - 1;
            end else begin
                state = DONE;
                busy = 0;
                done = 1;
            end
        end
    end
endmodule