module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    output reg  [WIDTH/2-1:0] final_root,
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg done
);

    reg [WIDTH-1:0] remainder, odd;
    reg [WIDTH/2-1:0] square_root;
    reg [2:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            remainder <= num;
            odd <= 1;
            square_root <= 0;
            done <= 0;
        end else begin
            case (state)
                0: begin
                    if (start) begin
                        state <= 1;
                        remainder <= num;
                        odd <= 1;
                        square_root <= 0;
                        done <= 0;
                    end else
                        state <= 0;
                end
                1: begin
                    if (remainder >= odd) begin
                        remainder <= remainder - odd;
                        square_root <= square_root + 1;
                        odd <= odd + 2;
                        state <= 1;
                    end else begin
                        final_root <= square_root;
                        done <= 1;
                        state <= 0;
                    end
                end
            endcase
        end
    end

endmodule
