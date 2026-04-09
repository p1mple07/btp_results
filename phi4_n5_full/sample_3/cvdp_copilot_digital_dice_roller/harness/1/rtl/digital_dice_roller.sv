module digital_dice_roller(
    input  logic         clk,
    input  logic         reset_n,
    input  logic         button,
    output logic [2:0]   dice_value
);

    // Define FSM states
    typedef enum logic { IDLE, ROLLING } state_t;
    state_t state, next_state;

    // Internal 3-bit counter for dice values (valid range: 1 to 6)
    logic [2:0] counter;

    // FSM sequential process
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Asynchronous reset: go to IDLE and clear outputs
            state      <= IDLE;
            counter    <= 3'b000;
            dice_value <= 3'b000;
        end else begin
            case (state)
                IDLE: begin
                    if (button == 1) begin
                        // Transition to ROLLING state and initialize counter to 1
                        state      <= ROLLING;
                        counter    <= 3'b001;
                        dice_value <= 3'b001;
                    end else begin
                        // Remain in IDLE; keep the last dice value unchanged
                        state      <= IDLE;
                    end
                end

                ROLLING: begin
                    if (button == 0) begin
                        // Button released: return to IDLE while retaining the last counter value
                        state      <= IDLE;
                    end else begin
                        // Button remains HIGH: update counter in modulo-6 fashion
                        if (counter == 3'b110) // If counter == 6
                            counter <= 3'b001; // Wrap around to 1
                        else
                            counter <= counter + 1;
                        dice_value <= counter;
                    end
                end
            endcase
        end
    end

endmodule