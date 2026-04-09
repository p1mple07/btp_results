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
                    if (measure_B) begin
                        stateA <= A_COUNT;
                    end else begin
                        stateA <= A_IDLE;
                    end
                end
                A_COUNT: begin
                    b_count <= b_count + 1;
                    if (b_count >= 16) begin
                        done_A <= 1;
                        stateA <= A_DONE;
                    end
                end
                A_DONE: begin
                    // Insert code here to: Handle any optional reset or idle logic
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
                    if (measure_A) begin
                        stateB <= B_COUNT;
                    end else begin
                        stateB <= B_IDLE;
                    end
                end
                B_COUNT: begin
                    a_count <= a_count + 1;
                    if (a_count >= 16) begin
                        done_B <= 1;
                        stateB <= B_DONE;
                    end
                end
                B_DONE: begin
                    // Insert code here to: Handle any optional reset or idle logic
                end
                default: stateB <= B_IDLE;
            endcase
        end
    end

    // Combine results
    // valid = done_A && done_B
    always @(*) begin
        if (!rst_n) begin
            valid = 0;
            A_faster_than_B = 0;
        end else begin
            valid = (done_A && done_B);
            if (valid) begin
                // Insert code here to: Compare periodA and periodB
            end else begin
                A_faster_than_B = 0;
            end
        end
    }

endmodule