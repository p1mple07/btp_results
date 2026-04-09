module iir_filter (
    input logic clk,
    input logic rst,
    input logic signed [15:0] x,
    output logic signed [15:0] y
);

    parameter signed [15:0] b0 = 16'h0F00;
    parameter signed [15:0] b1 = 16'h0E00;
    parameter signed [15:0] b2 = 16'h0D00;
    parameter signed [15:0] b3 = 16'h0C00;
    parameter signed [15:0] b4 = 16'h0B00;
    parameter signed [15:0] b5 = 16'h0A00;
    parameter signed [15:0] b6 = 16'h0900;
    parameter signed [15:0] a1 = -16'h0800;
    parameter signed [15:0] a2 = -16'h0700;
    parameter signed [15:0] a3 = -16'h0600;
    parameter signed [15:0] a4 = -16'h0500;
    parameter signed [15:0] a5 = -16'h0400;
    parameter signed [15:0] a6 = -16'h0300;

    logic signed [31:0] temp_y;
    logic [7:0] shift_reg_x [6];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg_x <= (8'h0000, 8'h0000, 8'h0000, 8'h0000, 8'h0000, 8'h0000);
        else begin
            temp_y = (b0 * x + b1 * shift_reg_x[0] + b2 * shift_reg_x[1] + b3 * shift_reg_x[2] +
                      b4 * shift_reg_x[3] + b5 * shift_reg_x[4] + b6 * shift_reg_x[5] -
                      a1 * shift_reg_y[0] - a2 * shift_reg_y[1] - a3 * shift_reg_y[2] -
                      a4 * shift_reg_y[3] - a5 * shift_reg_y[4] - a6 * shift_reg_y[5]) >>> 16;
            
            y <= temp_y;
            
            if (x > 16'h8000) 
                y <= 16'h7FFF; 

            shift_reg_y <= (temp_y, shift_reg_y[0], shift_reg_y[1], shift_reg_y[2], shift_reg_y[3], shift_reg_y[4]);
        end
    end
endmodule