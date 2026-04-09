module factorial (
    input wire clk,
    input wire arst_n,
    input wire num_in,
    input wire start,
    output reg busy,
    output reg [63:0] fact,
    output reg [63:0] done
);

reg state;
reg busy_flag;

initial begin
    state = IDLE;
    busy_flag = 0;
end

always @(posedge clk) begin
    if (arst_n) begin
        state <= IDLE;
        busy <= 0;
        fact = 1;
        done = 0;
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= BUSY;
                    busy_flag = 1;
                end
            end
            BUSY: begin
                if (num_in > 0) begin
                    for (int i = 1; i <= num_in; i = i + 1) begin
                        fact = fact * i;
                    end
                end
                done <= 1;
                busy_flag = 0;
            end
            DONE: begin
                fact <= fact;
                done <= 0;
            end
        endcase
    end
end

endmodule
