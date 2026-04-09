module square_root_seq #(parameter WIDTH = 16) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [WIDTH-1:0] num,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);

    reg [WIDTH-1:0] remainder, odd, temp_square, next_odd;
    integer i, j;
    reg [WIDTH/2-1:0] root = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            remainder <= num;
            root <= 0;
            odd <= 1;
            temp_square <= 0;
            next_odd <= 3;
            done <= 0;
        end else if (start) begin
            remainder <= num;
            root <= 0;
            odd <= 1;
            temp_square <= 0;
            next_odd <= 3;
            done <= 0;
        end else if (done) begin
            done <= 0;
        end
    end

    always @(posedge clk) begin
        if (start && !done) begin
            temp_square <= 0;
            odd <= 1;
            next_odd <= odd + 2;
            root <= 0;
            done <= 1;
        end

        if (done) begin
            final_root <= root;
        end else begin
            if (remainder >= odd) begin
                temp_square <= root << (WIDTH/2-1 - log2(odd));
                remainder <= remainder - odd;
                root <= root + 1;
                odd <= next_odd;
                next_odd <= odd + 2;
            end else begin
                done <= 1;
                final_root <= root;
            end
        end
    end

endmodule
