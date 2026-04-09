module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    input  wire clock,
    input  wire rst,
    input  wire start,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    reg [WIDTH-1:0] remainder;
    reg [1:0] odd;
    reg [WIDTH/2-1:0] square_root;
    reg state;
    integer i;

    state initial, compute;
    
    always @posedge clock or posedge rst
    begin
        if (rst) 
            state = initial;
        else if (start) 
            state = compute;
        end
    end

    initial: 
        if (start) 
            remainder = num;
            square_root = 0;
            odd = 1;
            state = compute;
        end
    compute: 
        while (remainder >= odd) 
        begin
            remainder = remainder - odd;
            square_root = square_root + 1;
            odd = odd + 2;
        end
        done = 1;
        final_root = square_root;
    end
endmodule