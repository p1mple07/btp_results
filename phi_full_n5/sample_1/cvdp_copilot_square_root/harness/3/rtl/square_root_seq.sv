
module square_root_seq #(parameter WIDTH = 16) (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] num,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    reg [WIDTH-1:0] remainder, current_odd;
    reg [WIDTH/2-1:0] square_root;

    // State machine initialization
    initial begin
        remainder = num;
        square_root = 0;
        current_odd = 1;
        done = 0;
    end

    // State machine logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Asynchronous reset
            remainder <= 0;
            current_odd <= 1;
            square_root <= 0;
            done <= 0;
        end else if (start) begin
            // Synchronized reset and start
            remainder <= num;
            current_odd <= 1;
            square_root <= 0;
            done <= 0;
        end else if (done) begin
            // IDLE state
            final_root <= 0;
        end else if (remainder >= current_odd) begin
            // COMPUTE state
            square_root <= square_root + 1;
            remainder <= remainder - current_odd;
            current_odd <= current_odd + 2;
            if (remainder < current_odd) begin
                // Computation complete
                final_root <= square_root;
                done <= 1;
            end
        end
    end

endmodule
