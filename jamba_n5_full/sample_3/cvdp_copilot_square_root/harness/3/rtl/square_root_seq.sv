module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    output reg  [WIDTH/2-1:0] final_root,
    output reg  done,
    input  wire clk,
    input  wire rst,
    input  wire start
);

    reg [WIDTH-1:0] remainder;
    reg [WIDTH/2-1:0] odd;
    reg [WIDTH/2-1:0] temp;
    reg [WIDTH/2-1:0] square_root;
    bit done;

initial begin
    finish();
end

always @(posedge clk or posedge rst) begin
    if (rst)
        remainder <= 0;
        odd <= 1;
        square_root <= 0;
        done <= 0;
    else
        if (start)
            remainder = num;
            odd = 1;
            square_root = 0;
            done <= 0;
        else
            if (done)
                finish();
            else
                if (remainder >= odd)
                    remainder = remainder - odd;
                    square_root++;
                    odd += 2;
                else
                    done <= 1;
        end
end

always @(negedge clk) begin
    if (done)
        finish();
end

assign final_root = square_root;

endmodule
