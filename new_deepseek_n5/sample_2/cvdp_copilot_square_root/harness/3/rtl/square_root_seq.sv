module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    input  wire clock,
    input  wire rst,
    input  wire start,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    reg [WIDTH-1:0] remainder, square_root;
    reg [WIDTH/2-1:0] odd;
    reg state;
    integer i;

    always @posedge clock begin
        if (rst) begin
            state = IDLE;
            remainder = num;
            square_root = 0;
            odd = 1;
        end else if (start) begin
            state = IDLE;
            remainder = num;
            square_root = 0;
            odd = 1;
        end else if (state == IDLE && !start) begin
            state = IDLE;
        end else if (state == IDLE) begin
            remainder = num;
            square_root = 0;
            odd = 1;
            state = COMPUTE;
        end else if (state == COMPUTE) begin
            if (remainder >= odd) begin
                remainder = remainder - odd;
                square_root = square_root + 1;
                odd = odd + 2;
                state = COMPUTE;
            end else begin
                done = 1;
                state = IDLE;
            end
        end
    end
endmodule