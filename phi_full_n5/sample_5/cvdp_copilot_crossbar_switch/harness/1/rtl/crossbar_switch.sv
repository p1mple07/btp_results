// ----------------------------------------
// - Procedural blocks
// ----------------------------------------
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        out0 <= 0;
        out1 <= 0;
        out2 <= 0;
        out3 <= 0;
        valid_out0 <= 1'b0;
        valid_out1 <= 1'b0;
        valid_out2 <= 1'b0;
        valid_out3 <= 1'b0;
    end else begin
        out0 <= 0 ;
        out1 <= 0 ;
        out2 <= 0 ;
        out3 <= 0 ;
        valid_out0 <= 1'b0;
        valid_out1 <= 1'b0;
        valid_out2 <= 1'b0;
        valid_out3 <= 1'b0;

        if (valid_in0 == 1) begin
            // Assign output for in0 with highest priority
            case (dest0)
                0: out0 <= in0;
                1: out0 <= in1;
                2: out0 <= in2;
                3: out0 <= in3;
                default: out0 <= 0;
            endcase
            valid_out0 <= valid_in0;
        end else if (valid_in1 == 1) begin
            // Assign output for in1 with highest priority
            case (dest1)
                0: out1 <= in0;
                1: out1 <= in1;
                2: out1 <= in2;
                3: out1 <= in3;
                default: out1 <= 0;
            endcase
            valid_out1 <= valid_in1;
        end else if (valid_in2 == 1) begin
            // Assign output for in2 with highest priority
            case (dest2)
                0: out2 <= in0;
                1: out2 <= in1;
                2: out2 <= in2;
                3: out2 <= in3;
                default: out2 <= 0;
            endcase
            valid_out2 <= valid_in2;
        end else if (valid_in3 == 1) begin
            // Assign output for in3 with highest priority
            case (dest3)
                0: out3 <= in0;
                1: out3 <= in1;
                2: out3 <= in2;
                3: out3 <= in3;
                default: out3 <= 0;
            endcase
            valid_out3 <= valid_in3;
        end else begin
            // No valid input, outputs remain zero
            out0 <= 0;
            out1 <= 0;
            out2 <= 0;
            out3 <= 0;
        end
    end
end
