`timescale 1ns/1ps

module FindFasterClock(
    input  wire clk_A,
    input  wire clk_B,
    input  wire rst_n,            // Active-low reset
    output reg  A_faster_than_B,  // 1 if clk_A is faster
    output reg  valid             // 1 once both clocks have measured a period
);

    reg        measure_B;          
    reg [31:0] b_count;            
    reg [31:0] periodA;            
    reg        done_A;             
    reg        measure_A;
    reg [31:0] a_count;
    reg [31:0] periodB;            
    reg        done_B;

    // A‑domain FSM for measuring periodA
    reg [1:0] stateA;  
    localparam A_IDLE    = 2'd0,
               A_COUNT   = 2'd1,
               A_DONE    = 2'd2;
    // B‑domain FSM for measuring periodB
    reg [1:0] stateB;
    localparam B_IDLE    = 2'd0,
               B_COUNT   = 2'd1,
               B_DONE    = 2'd2;

    // Clock A FSM
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
                    if (clk_B) begin
                        measure_A <= 1;
                        measure_B <= 0;
                        b_count <= 0;
                        stateA <= A_COUNT;
                    end else begin
                        stateA <= A_IDLE;
                    end
                end
                A_COUNT: begin
                    if (clk_B) begin
                        a_count <= a_count + 1;
                    end
                    if (done_A) begin
                        stateA <= A_DONE;
                    end else begin
                        stateA <= A_COUNT;
                    end
                end
                A_DONE: begin
                    done_A <= 1;
                    periodA = b_count;
                end
                default: stateA <= A_IDLE;
            endcase
        end
    end

    // Clock B FSM
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
                    if (clk_A) begin
                        measure_B <= 1;
                        measure_A <= 0;
                        a_count <= 0;
                        stateB <= A_IDLE;
                    end else begin
                        stateB <= B_IDLE;
                    end
                end
                B_COUNT: begin
                    if (clk_A) begin
                        b_count <= b_count + 1;
                    end
                    if (done_B) begin
                        stateB <= B_DONE;
                    end else begin
                        stateB <= B_COUNT;
                    end
                end
                B_DONE: begin
                    done_B <= 1;
                    periodB = a_count;
                end
                default: stateB <= B_IDLE;
            endcase
        end
    end

    // Output logic
    assign A_faster_than_B = (periodB > periodA) ? 1 : 0;
    assign valid = done_A && done_B;

endmodule
