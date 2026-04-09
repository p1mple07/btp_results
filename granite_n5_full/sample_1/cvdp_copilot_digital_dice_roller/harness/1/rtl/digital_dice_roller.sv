module digital_dice_roller (
    input logic clk,
    input logic reset_n,
    input logic button,
    output logic [2:0] dice_value
);

logic [2:0] counter;

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        dice_value <= 3'b000;
        counter <= 3'b000;
    end else begin
        if (button == 1'b1 && dice_value!= 3'b111) begin
            counter <= counter + 1;
        end else if (button == 1'b0 && dice_value!= 3'b111) begin
            counter <= 3'b000;
        end
        
        if (counter == 3'b000) begin
            dice_value <= 3'b000;
        end else if (counter == 3'b001) begin
            dice_value <= 3'b001;
        end else if (counter == 3'b010) begin
            dice_value <= 3'b010;
        } else if (counter == 3'b011) begin
            dice_value <= 3'b011;
        } else if (counter == 3'b100) begin
            dice_value <= 3'b100;
        } else if (counter == 3'b101) begin
            dice_value <= 3'b101;
        } else if (counter == 3'b110) begin
            dice_value <= 3'b110;
        } else if (counter == 3'b111) begin
            dice_value <= 3'b111;
        }
    end
end

endmodule