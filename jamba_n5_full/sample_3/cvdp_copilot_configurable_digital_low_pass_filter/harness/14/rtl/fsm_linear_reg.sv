module fsm_linear_reg #(
    parameter DATA_WIDTH = 16
)(
    input  clk,
    input  reset,
    input  start,
    input  x_in,
    input  w_in,
    input  b_in,
    output reg [2*DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH:0] result2,
    output reg done
);

    // Internal signals
    localparam IDLE = 2'b00,
        COMPUTE = 2'b01,
        DONE = 2'b10;

    always @(posedge clk or reset) begin
        if (reset) begin
            result1 <= 0;
            result2 <= 0;
            done <= 0;
        end else if (start) begin
            state <= COMPUTE;
        end else begin
            state <= IDLE;
        end
    end

    always @(state) begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= COMPUTE;
                end
            end
            COMPUTE: begin
                // Weighted sum: w_in * x_in shifted left by 1 (equivalent to multiply by 2)
                result1 <= {[DATA_WIDTH-1:0] w_in*x_in};
                // Bias-adjusted sum: b_in + (x_in >> 2)
                result2 <= b_in + {[DATA_WIDTH-1:0] (x_in >> 2)};
                done <= 1'b1;
            end
            DONE: begin
                done <= 1'b0;
            end
        endcase
    end

endmodule
