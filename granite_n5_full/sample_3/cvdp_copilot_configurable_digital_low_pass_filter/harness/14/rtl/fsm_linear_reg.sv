module fsm_linear_reg(
    // System signals
    input clk,
    input reset,
    input start,
    // Data I/O ports
    input [DATA_WIDTH-1:0] x_in,
    input [DATA_WIDTH-1:0] w_in,
    input [DATA_WIDTH-1:0] b_in,
    // Data O/P ports
    output reg [2*DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH+1:0] result2,
    output reg done
);

// Define internal signals
reg [DATA_WIDTH-1:0] result1_internal;
reg [DATA_WIDTH+1:0] result2_internal;
reg state;

// State transition table
always @(*) begin
    case(state)
        IDLE: begin
            if(start) begin
                result1_internal <= 0;
                result2_internal <= 0;
                state <= COMPUTE;
            end else begin
                result1_internal <= 0;
                result2_internal <= 0;
                state <= IDLE;
            end
        end
        COMPUTE: begin
            result1_internal <= w_in * x_in >>> 1;
            result2_internal <= b_in + (x_in >>> 2);
            state <= DONE;
        end
        DONE: begin
            done <= 1;
            state <= IDLE;
        end
        default: begin
            state <= IDLE;
        end
    endcase
end

// Assign output signals based on current state
assign result1 = result1_internal;
assign result2 = result2_internal;

endmodule