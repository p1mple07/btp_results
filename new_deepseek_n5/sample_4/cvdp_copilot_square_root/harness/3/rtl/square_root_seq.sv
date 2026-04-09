module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    input  wire clock,
    input  wire rst,
    input  wire start,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    reg [WIDTH-1:0] remainder, square;
    reg [WIDTH/2-1:0] test_bit, temp_square;
    reg [WIDTH/2-1:0] square_root;
    reg [WIDTH-1:0] odd_num;
    reg [WIDTH-1:0] j;
    reg [WIDTH-1:0] temp_square;
    integer state;

    integer i;

    always @posedge clock or posedge rst) begin
        if (rst) begin
            remainder = 0;
            square = 0;
            square_root = 0;
            odd_num = 1;
            j = WIDTH-1;
            state = IDLE;
        end else if (start) begin
            state = IDLE;
        end else if (state == IDLE) begin
            if (num > 0) begin
                remainder = num;
                square_root = 0;
                odd_num = 1;
                j = WIDTH-1;
                state = COMPUTE;
            end
        end else if (state == COMPUTE) begin
            while (remainder >= odd_num) begin
                if (remainder >= (odd_num << j)) begin
                    remainder = remainder - (odd_num << j);
                    square_root = square_root + (1 << j);
                end
                j = j - 1;
            end
            state = IDLE;
            done = 1;
        end
    end
endmodule