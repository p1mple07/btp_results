module square_root_seq #(parameter WIDTH = 16) (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] num,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);
    reg [WIDTH-1:0] remainder, current_odd, next_odd;
    reg [WIDTH/2-1:0] temp_square;
    integer i, j;
    reg [WIDTH-1:0] state, next_state;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            remainder <= num;
            final_root <= 0;
            current_odd <= 1;
            next_odd <= 1;
            temp_square <= 0;
            state <= IDLE;
            done <= 0;
        end else if (start) begin
            remainder <= num;
            current_odd <= 1;
            next_odd <= 1;
            temp_square <= 0;
            state <= IDLE;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        final_root <= 0;
                        remainder <= num;
                        current_odd <= 1;
                        next_odd <= 1;
                        temp_square <= 0;
                        state <= COMPUTE;
                        done <= 0;
                    end
                end
                COMPUTE: begin
                    if (remainder >= current_odd) begin
                        temp_square <= (final_root << 1) | current_odd;
                        for (i = 0; i < WIDTH; i = i + 1) begin
                            if (temp_square[i]) begin
                                temp_square = temp_square << 1;
                                temp_square[WIDTH-1] = 0;
                            end
                        end
                        if (temp_square <= remainder) begin
                            final_root <= final_root + 1;
                            remainder <= remainder - current_odd;
                            current_odd <= next_odd;
                            next_odd <= current_odd + 2;
                        end
                    end
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule