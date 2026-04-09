
module square_root_seq #(parameter WIDTH = 16) (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] num,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    reg [WIDTH-1:0] remainder, temp_root;
    reg [WIDTH-1:0] odd;
    reg [WIDTH/2-1:0] test_bit;
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            final_root <= 0;
            done <= 0;
            odd <= 1;
            remainder <= num;
        end else begin
            if (start) begin
                if (done) begin
                    final_root <= 0;
                    odd <= 1;
                    remainder <= num;
                    done <= 0;
                end
                else begin
                    done <= 1;
                end
            end

            if (done) begin
                final_root <= remainder;
                done <= 0;
            end

            if (remainder >= odd) begin
                temp_root <= remainder - odd;
                odd <= odd + 2;
                final_root <= final_root + 1;
            end

            if (temp_root < remainder) begin
                done <= 1;
                final_root <= temp_root;
            end
        end
    end
endmodule
