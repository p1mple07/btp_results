module FindFasterClock (
    input wire clk_A,
    input wire clk_B,
    input wire rst_n,
    output reg A_faster_than_B,
    output reg valid
);

    reg measure_B;
    reg [31:0] b_count;
    reg [31:0] periodA;
    reg done_A;
    reg measure_A;
    reg [31:0] a_count;
    reg [31:0] periodB;
    reg done_B;

    reg [1:0] stateA;
    reg [1:0] stateB;

    always @(posedge clk_A or negedge rst_n) begin
        if (!rst_n) begin
            stateA <= A_IDLE;
            measure_B <= 0;
            b_count <= 0;
            periodA <= 0;
            done_A <= 0;
        end else begin
            case (stateA)
                A_IDLE: begin
                    if (measure_A) begin
                        stateA <= A_COUNT;
                    end else begin
                        stateA <= A_IDLE;
                    end
                end
                A_COUNT: begin
                    if (measure_A) begin
                        b_count <= b_count + 1;
                    end
                    if (b_count == 32) begin // arbitrary, but we can stop after some cycles
                        stateA <= A_DONE;
                        done_A <= 1;
                    end
                end
                A_DONE: begin
                    // nothing
                end
                default: stateA <= A_IDLE;
            endcase
        end
    end

    always @(posedge clk_B or negedge rst_n) begin
        if (!rst_n) begin
            stateB <= B_IDLE;
            measure_A <= 0;
            a_count <= 0;
            periodB <= 0;
            done_B <= 0;
        end else begin
            case (stateB)
                B_IDLE: begin
                    if (measure_B) begin
                        stateB <= B_COUNT;
                    end else begin
                        stateB <= B_IDLE;
                    end
                end
                B_COUNT: begin
                    if (measure_B) begin
                        a_count <= a_count + 1;
                    end
                    if (a_count == 32) begin
                        stateB <= B_DONE;
                        done_B <= 1;
                    end
                end
                B_DONE: begin
                    // nothing
                end
                default: stateB <= B_IDLE;
            endcase
        end
    end

    // Output logic
    assign A_faster_than_B = (periodB > periodA) ? 1 : 0;
    assign valid = done_A && done_B;

endmodule
