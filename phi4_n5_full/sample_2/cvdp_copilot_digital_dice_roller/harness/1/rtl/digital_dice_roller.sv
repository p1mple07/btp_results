module digital_dice_roller (
    input  logic         clk,
    input  logic         reset_n,
    input  logic         button,
    output logic [2:0]   dice_value
);

    // Define the two FSM states: IDLE and ROLLING.
    typedef enum logic {IDLE, ROLLING} state_t;
    state_t state, next_state;
    logic [2:0] counter;
    logic [2:0] next_counter;

    // Sequential logic: update state, counter, and output on clock edge or asynchronous reset.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state      <= IDLE;
            counter    <= 3'b000; // Not a valid dice value but per spec on reset.
            dice_value <= 3'b000;
        end else begin
            state      <= next_state;
            counter    <= next_counter;
            // In ROLLING state, update dice_value with the current counter value.
            // In IDLE state, hold the last dice_value.
            dice_value <= (state == ROLLING) ? counter : dice_value;
        end
    end

    // Combinational logic: determine next state and counter value.
    always_comb begin
        next_state    = state;
        next_counter  = counter;
        case (state)
            IDLE: begin
                // Transition to ROLLING when button is HIGH.
                if (button) begin
                    next_state    = ROLLING;
                    next_counter  = 3'b001; // Start counting at 1.
                end
            end
            ROLLING: begin
                // If button becomes LOW, return to IDLE.
                if (!button) begin
                    next_state = IDLE;
                end else begin
                    // When button is HIGH, increment the counter on every clock edge.
                    // Ensure the counter cycles between 1 and 6.
                    if (counter == 3'b110) begin
                        next_counter = 3'b001;
                    end else begin
                        next_counter = counter + 1;
                    end
                end
            end
            default: begin
                next_state    = IDLE;
                next_counter  = counter;
            end
        endcase
    end

endmodule