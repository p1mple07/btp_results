`timescale 1ns/1ps

module FindFasterClock(
    input  wire clk_A,
    input  wire clk_B,
    input  wire rst_n,            // Active-low reset
    output reg  A_faster_than_B,  // 1 if clk_A is measured faster
    output reg  valid             // 1 once both clocks have measured a period
);

    //----------------------------------------
    // Internal signals
    //----------------------------------------
    reg        measure_B;          
    reg [31:0] b_count;            
    reg [31:0] periodA;            
    reg        done_A;             
    reg        measure_A;
    reg [31:0] a_count;
    reg [31:0] periodB;            
    reg        done_B;

    // A-domain FSM for measuring "periodA"
    reg [1:0] stateA;  
    localparam A_IDLE    = 2'd0,
               A_COUNT   = 2'd1,
               A_DONE    = 2'd2;
    // B-domain FSM for measuring "periodB"
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
                    // Add your logic here to: Complete the transition logic.
                end
                A_COUNT: begin
                    // Add your logic here to: Capture b_count and transition to A_DONE.
                end
                A_DONE: begin
                    // Add your logic here to: Handle any optional reset or idle logic.
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
                    // Add your logic here to: Complete the transition logic.
                end
                B_COUNT: begin
                    // Add your logic here to: Capture a_count and transition to B_DONE.
                end
                B_DONE: begin
                    // Add your logic here to: Handle any optional reset or idle logic.
                end
                default: stateB <= B_IDLE;
            endcase
        end
    end

    // In B-domain, if measure_B=1, increment b_count.
    always @(*) begin
        if (!rst_n) begin
            b_count <= 0;
        end else if (measure_B) begin
            // Add your logic here to: Increment b_count.
        end
    }

    // In A-domain, if measure_A=1, increment a_count.
    always @(posedge clk_A) begin
        a_count <= a_count + 1.
    }

}