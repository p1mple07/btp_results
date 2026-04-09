module dice_roller (
    input wire clk,
    input wire reset_n,
    input wire button,
    output reg [2:0] dice_value
);

    reg [2:0] counter;
    reg [1:0] state;

    always @(posedge clk or negedge reset_n) begin
        if (reset_n) begin
            state <= IDLE;
            counter <= 0;
            dice_value <= "000";
        end else begin
            case (state)
                IDLE: begin
                    if (button) begin
                        state <= ROLLING;
                        counter <= 1;
                    end else
                        dice_value <= "000";
                end
                ROLLING: begin
                    if (button) begin
                        counter <= counter + 1;
                        if (counter == 6) counter <= 0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    always @(*) begin
        case (state)
            IDLE: dice_value = "000";
            ROLLING: dice_value = counter;
        endcase
    end

endmodule
