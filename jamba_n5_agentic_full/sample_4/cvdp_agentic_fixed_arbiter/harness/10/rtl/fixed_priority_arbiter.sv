`timescale 1ns / 1ps
module fixed_priority_arbiter(
    input        clk,
    input        reset,
    input        enable,
    input        clear,
    input  [7:0] req,
    input  [7:0] priority_override,

    output reg [7:0] grant,
    output reg       valid,
    output reg [2:0] grant_index,
    output reg [2:0] active_grant
);

    always @(posedge clk or posedge reset or posedge enable or posedge clear) begin
        if (reset) begin
            grant <= 8'b00000000;
            valid <= 1'b0;
            grant_index <= 3'b000;
        end else if (clear) begin
            grant <= 8'b00000000;
            valid <= 1'b0;
            grant_index <= 3'b000;
        end else if (enable) begin
            // proceed with normal logic
            if (priority_override != 8'b00000000) begin
                grant <= priority_override;
                valid <= 1'b1;
                grant_index <= (priority_override[0] ? 3'd0 :
                                priority_override[1] ? 3'd1 :
                                priority_override[2] ? 3'd2 :
                                priority_override[3] ? 3'd3 :
                                priority_override[4] ? 3'd4 :
                                priority_override[5] ? 3'd5 :
                                priority_override[6] ? 3'd6 :
                                priority_override[7] ? 3'd7 : 3'd0);
            end else if (req[0]) begin
                grant <= 8'b00000001;
                grant_index <= 3'd0;
                valid <= 1'b1;
            end else if (req[1]) begin
                grant <= 8'b00000010;
                grant_index <= 3'd1;
                valid <= 1'b1;
            end else if (req[2]) begin
                grant <= 8'b00000100;
                grant_index <= 3'd2;
                valid <= 1'b1;
            end else if (req[3]) begin
                grant <= 8'b00001000;
                grant_index <= 3'd3;
                valid <= 1'b1;
            end else if (req[4]) begin
                grant <= 8'b00010000;
                grant_index <= 3'd4;
                valid <= 1'b1;
            end else if (req[5]) begin
                grant <= 8'b00100000;
                grant_index <= 3'd5;
                valid <= 1'b1;
            end else if (req[6]) begin
                grant <= 8'b01000000;
                grant_index <= 3'd6;
                valid <= 1'b1;
            end else if (req[7]) begin
                grant <= 8'b10000000;
                grant_index <= 3'd7;
                valid <= 1'b1;
            end else begin
                grant <= 8'b00000000;
                grant_index <= 3'd0;
                valid <= 1'b0;
            end
        end
    end
endmodule
