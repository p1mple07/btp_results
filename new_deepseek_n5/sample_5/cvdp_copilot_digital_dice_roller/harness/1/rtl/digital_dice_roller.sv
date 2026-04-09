Module declaration
module digital_dice_roller (
    input clock,
    input reset_n,
    input button,
    output dice_value
);

// FSM states
enum state : 1 bit {
    IDLE,
    ROLLING
};

// Variables
reg [2:0] counter = 0;
reg state fsm = IDLE;
wire dice_value[2:0];

// FSM transition
always @posedge clock or button
    case (fsm)
        IDLE:
            if (button) 
                fsm = ROLLING;
            else 
                fsm = IDLE;
        ROLLING:
            if (button) 
                fsm = IDLE;
            else 
                counter = (counter + 1) % 6;
                if (counter == 0) 
                    counter = 5;
                if (counter == 5) 
                    dice_value = 5;
                else 
                    dice_value = counter + 1;
    endcase

// Reset handling
always @negedge reset_n
    if (reset_n)
        fsm = IDLE;
        dice_value = 0;

// Output assignment
always
    dice_value = counter + 1;
endmodule