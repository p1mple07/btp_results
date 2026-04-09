// State declarations
enum state_type {
    IDLE,
    BUSY,
    DONE
}

// State variable
reg state_type state = IDLE;

// Input ports
input clock;
input arst_n;
input [4:0] num_in;

// Output ports
output [63:0] fact;
output done;

// FSM transition table
always_ff @ (posedge clock or falling edge arst_n) begin
    case (state)
        IDLE: 
            if (num_in == 0) state = BUSY;
            // else: state = BUSY (since start is required for num_in >0)
        BUSY: 
            if (done) state = DONE;
        DONE: 
            state = IDLE;
    endcase
end

// Factorial computation
always @ (posedge clock) begin
    if (state == BUSY) begin
        // Initialize factorial to 1
        fact = 1;
        
        // Compute factorial in num_in steps
        for (int i = 2; i <= num_in; i++) begin
            fact = fact * i;
        end
    end
end