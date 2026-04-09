module fsm_linear_reg #(
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [DATA_WIDTH-1:0] x_in,
    input wire [DATA_WIDTH-1:0] w_in,
    input wire [DATA_WIDTH-1:0] b_in,
    output reg [2*DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH]: result2,
    output bit done
);

    localparam NUM_STATES = 3;
    reg [NUM_STATES-1:0] state;
    reg done_flag;

    initial begin
        state = IDLE;
        done_flag = 1'b0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done_flag = 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= COMPUTE;
                    end
                    done_flag = 1'b0;
                end
                COMPUTE: begin
                    result1 = w_in * x_in >>> 1;
                    result2 = b_in + (x_in >>> 2);
                    done_flag = 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end

    assign done = done_flag;

    assign result1 = w_in * x_in >>> 1;
    assign result2 = b_in + (x_in >>> 2);

endmodule
