`timescale 1ns / 1ps

module async_filo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
) (
    input logic w_clk,
    input logic r_clk,
    input logic w_rst,
    input logic r_rst,
    input logic push,
    input logic pop,
    input logic [DATA_WIDTH-1:0] w_data,
    input logic [DATA_WIDTH-1:0] r_data,
    output logic r_empty,
    output logic w_full
);

reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];
reg w_ptr, r_ptr;
logic w_full, r_empty;

initial begin
    w_ptr = 0;
    r_ptr = 0;
    w_full = 0;
    r_empty = 1;
end

always @(*) begin
    w_ptr = bin2gray(w_ptr ^ 1);
    r_ptr = bin2gray(r_ptr ^ 1);

    if (push && !w_full) begin
        mem[w_ptr] = w_data;
        w_ptr = w_ptr + 1;
        w_full = w_ptr == DEPTH;
    end

    if (pop && !r_empty) begin
        r_data = mem[r_ptr];
        r_ptr = r_ptr + 1;
        r_empty = r_ptr == DEPTH;
    end
end

assign r_empty = r_ptr == DEPTH;
assign w_full = w_ptr == DEPTH;

endmodule
