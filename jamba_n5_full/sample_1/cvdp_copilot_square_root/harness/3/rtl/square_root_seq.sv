module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    output reg  [WIDTH/2-1:0] final_root,
    output logic done
);

reg [WIDTH-1:0] remainder, square;
integer i, j;

initial begin
    remainder = num;
    odd   = 1;
    square = 0;
    final_root = 0;
    done    = 0;
end

always @(posedge clk) begin
    if (start) begin
        remainder = num;
        odd   = 1;
        square = 0;
        done   = 0;
    end
end

always @(posedge clk) begin
    if (done) begin
        done = 0;
        return;
    end
end

always @(posedge clk) begin
    if (remainder < odd) begin
        odd   = odd + 2;
    end else begin
        final_root = odd;
        done = 1;
    end
end

endmodule
