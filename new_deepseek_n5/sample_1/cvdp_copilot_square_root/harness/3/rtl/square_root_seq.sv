module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,       
    input  wire clock,
    input  wire [WIDTH/2-1:0] start,
    input  wire rst,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    state state = IDLE;
    reg [WIDTH-1:0] remainder = num;
    reg [WIDTH/2-1:0] root = 0;
    reg [WIDTH/2-1:0] odd = 1;
    reg clock_enable = 1;
    
    always @clock_enable
    begin
        if (rst) begin
            state = IDLE;
            remainder = num;
            root = 0;
            odd = 1;
            clock_enable = 0;
            return;
        end
        
        if (start) begin
            state = COMPUTE;
            clock_enable = 1;
        end
        
        case (state)
            IDLE:
                if (rst) begin
                    state = IDLE;
                    remainder = num;
                    root = 0;
                    odd = 1;
                    clock_enable = 0;
                    return;
                end
                if (start) begin
                    state = COMPUTE;
                    clock_enable = 1;
                end
                next_state = IDLE;
                break;
            COMPUTE:
                if (remainder >= odd) begin
                    remainder = remainder - odd;
                    root = root + 1;
                    odd = odd + 2;
                    clock_enable = 1;
                end
                next_state = IDLE;
                break;
        endcase
    end
endmodule