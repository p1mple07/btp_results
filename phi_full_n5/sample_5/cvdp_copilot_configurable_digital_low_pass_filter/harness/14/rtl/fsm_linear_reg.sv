module fsm_linear_reg (
    input clk,
    input reset,
    input start,
    input [DATA_WIDTH-1:0] x_in,
    input [DATA_WIDTH-1:0] w_in,
    input [DATA_WIDTH-1:0] b_in,
    output reg [2*DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH:0] result2,
    output reg done
);

    // State declaration
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE = 2'b10;
    reg [1:0] state_reg = IDLE;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            result1 <= 0;
            result2 <= 0;
            done <= 0;
        end else begin
            case (state_reg)
                IDLE: begin
                    if (start) begin
                        state_reg <= COMPUTE;
                    end else begin
                        state_reg <= IDLE;
                    end
                end
                COMPUTE: begin
                    result1 <= (w_in * x_in) >>> 1;
                    result2 <= b_in + (x_in >>> 2);
                    done <= 1;
                    state_reg <= DONE;
                end
                DONE: begin
                    done <= 0;
                    state_reg <= IDLE;
                end
            endcase
        end
    end

    // Output logic
    always @(*) begin
        case (state_reg)
            IDLE: begin
                result1 <= 0;
                result2 <= 0;
                done <= 0;
            end
            COMPUTE: begin
                result1 <= (w_in * x_in) >>> 1;
                result2 <= b_in + (x_in >>> 2);
                done <= 1;
            end
            DONE: begin
                done <= 0;
            end
        endcase
    end

endmodule
 module fsm_linear_reg (
    input clk,
    input reset,
    input start,
    input [DATA_WIDTH-1:0] x_in,
    input [DATA_WIDTH-1:0] w_in,
    input [DATA_WIDTH-1:0] b_in,
    output reg [2*DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH:0] result2,
    output reg done
);

    // State declaration
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE = 2'b10;
    reg [1:0] state_reg = IDLE;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            result1 <= 0;
            result2 <= 0;
            done <= 0;
        end else begin
            case (state_reg)
                IDLE: begin
                    if (start) begin
                        state_reg <= COMPUTE;
                    end else begin
                        state_reg <= IDLE;
                    end
                end
                COMPUTE: begin
                    result1 <= (w_in * x_in) >>> 1;
                    result2 <= b_in + (x_in >>> 2);
                    done <= 1;
                    state_reg <= DONE;
                end
                DONE: begin
                    done <= 0;
                    state_reg <= IDLE;
                end
            endcase
        end
    end

    // Output logic
    always @(*) begin
        case (state_reg)
            IDLE: begin
                result1 <= 0;
                result2 <= 0;
                done <= 0;
            end
            COMPUTE: begin
                result1 <= (w_in * x_in) >>> 1;
                result2 <= b_in + (x_in >>> 2);
                done <= 1;
            end
            DONE: begin
                done <= 0;
            end
        endcase
    end

endmodule