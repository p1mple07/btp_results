module digital_dice_roller (
    input clk,
    input reset_n,
    input button,
    output reg [2:0] dice_value
);

    // State encoding
    typedef enum'(u[1:2]'({1'b0, 1'b1})) state_t;
    typedef enum'(u[1:2]'({1'b0, 1'b1})) next_state_t;

    // State register
    reg [1:0] state_reg;

    // Counter
    reg [2:0] counter;

    // State transition logic
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            state_reg <= 3'b000;
            counter <= 3'b000;
            dice_value <= 3'b000;
        end else begin
            case (state_reg)
                3'b000: begin
                    if (button)
                        state_reg <= 3'b001;
                    else
                        state_reg <= 3'b000;
                    dice_value <= 3'b000;
                    counter <= 3'b001;
                end
                3'b001: begin
                    if (counter == 3'b110)
                        state_reg <= 3'b000;
                    else
                        counter <= counter + 1'b1;
                    dice_value <= counter;
                end
            endcase
        end
    end

    // State flip logic
    always @(posedge clk) begin
        state_reg <= state_reg + 1'b1;
        if (state_reg > 3'b110)
            state_reg <= 3'b000;
    end

endmodule
