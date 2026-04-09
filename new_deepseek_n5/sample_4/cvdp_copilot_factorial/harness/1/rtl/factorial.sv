// State declarations
enum State { IDLE, BUSY, DONE };
reg State state = IDLE;

// Input ports
input clock;
input arst_n;
input [4:0] num_in;
input start;

// Output ports
output busy;
output [63:0] fact;
output done;

// FSM logic
always @* begin
    case (state)
        IDLE: 
            if (start && num_in[4:0] & arst_n) begin
                state = BUSY;
                busy = 1;
                done = 0;
            end
        BUSY: 
            if (done) begin
                state = DONE;
                busy = 0;
                done = 1;
            end
        DONE: 
            busy = 0;
            done = 0;
    endcase
end

// Factorial computation
always @posedge clock begin
    case (state)
        IDLE: 
            if (start && num_in & arst_n) begin
                state = BUSY;
                busy = 1;
                done = 0;
                reg [63:0] res = 1;
                reg reg [4:0] cnt = num_in;
                reg reg [4:0] i = 1;
                state = BUSY;
            end
        BUSY: 
            if (i <= num_in) begin
                res = res * (i);
                i = i + 1;
                state = BUSY;
            end
        DONE: 
            busy = 0;
            done = 1;
    endcase
end