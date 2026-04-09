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
            // Assign output data for valid input 0
            out0 <= in0;
            valid_out0 <= 1'b1;
        end else if (valid_in1 == 1) begin
            // Assign output data for valid input 1
            out1 <= in1;
            valid_out1 <= 1'b1;
        end else if (valid_in2 == 1) begin
            // Assign output data for valid input 2
            out2 <= in2;
            valid_out2 <= 1'b1;
        end else if (valid_in3 == 1) begin
            // Assign output data for valid input 3
            out3 <= in3;
            valid_out3 <= 1'b1;
        end else begin
            // No valid input, keep outputs at zero
        end
    end
end
