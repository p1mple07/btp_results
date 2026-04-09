// State declarations
enum state_t {
    IDLE,
    BUSY,
    DONE
};

// Input declarations
input clock;
input arst_n;
input [4:0] num_in;
input start;

// Output declarations
output [63:0] fact;
output done;

// Internal variables
state_t state = IDLE;
reg [63:0] num = 0;
reg [63:0] fact = 1;
reg [63:0] temp = 0;
reg i = 0;

// State transition logic
always_ff @(posedge clock or negedge arst_n) begin
    case(state)
        IDLE: 
            if (num_in & start) begin
                state = BUSY;
                num = num_in;
                done = 0;
            end
        BUSY: 
            if (i == num) begin
                state = DONE;
                done = 1;
                fact = temp;
            end else begin
                i = i + 1;
                temp = temp * i;
                fact = fact ^ (temp);
            end
        DONE: 
            busy = 0;
            done = 1;
    endcase
end