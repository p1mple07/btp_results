module digital_dice_roller #(parameter RESET_VALUE = 0) (
    input logic clk,
    input logic reset_n,
    input logic button,
    output logic [2:0] dice_value
);
    
    typedef enum logic [2:0] {
        IDLE,
        ROLLING
    } state_t;
    
    state_t state, next_state;
    logic [2:0] counter;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else
            state <= next_state;
        
        if (state == IDLE)
            dice_value <= RESET_VALUE;
        else if (state == ROLLING)
            dice_value <= counter;
    end
    
    always_comb begin
        case (state)
            IDLE: begin
                next_state = ROLLING;
                counter = 0;
            end
            ROLLING: begin
                if (button == 1'b1) begin
                    next_state = ROLLING;
                    counter++;
                end
                else begin
                    next_state = IDLE;
                    counter--;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
endmodule