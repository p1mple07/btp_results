module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    input  wire clocks,
    input  wire [WIDTH/2-1:0] start,
    input  wire rst,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    reg [WIDTH-1:0] remainder, square;
    reg [WIDTH/2-1:0] root, odd;
    integer i;
    wire [WIDTH-1:0] temp_square;
    
    state = 0;
    
    always @(*)
    begin
        if (rst) begin
            state = 0;
            remainder = 0;
            square = 0;
            root = 0;
            odd = 1;
        end
        else if (start) begin
            state = 1;
            remainder = num;
        end
    end
    
    always @posedge clocks
    begin
        case(state)
            0: state = 1;
            1: begin
                while (remainder >= odd) begin
                    remainder = remainder - odd;
                    root = root + 1;
                    temp_square = (root | odd);
                    square = 0;
                    for (i = 0; i < WIDTH; i = i + 1) begin
                        if (temp_square[i]) begin
                            square = square + (temp_square << i);
                        end
                    end
                    odd = odd + 2;
                end
                if (remainder < odd) begin
                    final_root = root;
                    done = 1;
                end
                state = 0;
            end
        end
    end
endmodule