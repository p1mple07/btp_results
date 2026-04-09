module fixed_priority_arbiter(
    input clk,
    input reset,
    input enable,
    input clear,
    input [7:0] req,
    input [7:0] priority_override,
    output reg [7:0] grant,
    output reg       valid,
    output reg [2:0] grant_index,
    output reg [2:0] active_grant); 

    always @(posedge clk or posedge reset or posedge enable) begin
        if (!enable) begin
            // Outputs remain unchanged
            return;
        end

        if (reset) begin
            grant <= 8'b00000000;
            valid <= 1'b0;
            grant_index <= 3'd0;
            active_grant <= 3'd0;
            return;
        end

        if (priority_override != 8'b00000000) begin
            grant <= priority_override;
            valid <= 1'b1;
            active_grant <= priority_override[2:0];
        end else begin
            if (req[0]) begin
                grant <= 8'b00000100;
                grant_index <= 3'd0;
                valid <= 1'b1;
            end else if (req[1]) begin
                grant <= 8'b00001000;
                grant_index <= 3'd1;
                valid <= 1'b1;
            end else if (req[2]) begin
                grant <= 8'b00010000;
                grant_index <= 3'd2;
                valid <= 1'b1;
            end else if (req[3]) begin
                grant <= 8'b00100000;
                grant_index <= 3'd3;
                valid <= 1'b1;
            end else if (req[4]) begin
                grant <= 8'b01000000;
                grant_index <= 3'd4;
                valid <= 1'b1;
            end else if (req[5]) begin
                grant <= 8'b10000000;
                grant_index <= 3'd5;
                valid <= 1'b1;
            end else {
                grant <= 8'b00000000;
                grant_index <= 3'd0;
                valid <= 1'b0;
            }
        end

        active_grant <= grant_index;
    end
endmodule