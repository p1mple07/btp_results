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
                    // Transition to COUNT when measure_B becomes 1
                    if (measure_B) begin
                        stateA <= A_COUNT;
                    end
                    else begin
                        stateA <= A_IDLE;
                    end
                end
                A_COUNT: begin
                    // Capture b_count and transition to A_DONE when periodB is measured
                    if (measure_B) begin
                        b_count <= b_count + 1;
                    end
                    else begin
                        stateA <= A_IDLE;
                    end
                    if (b_count >= periodB) begin
                        stateA <= A_DONE;
                        periodA <= b_count;
                    end
                end
                A_DONE: begin
                    // Reset counters and state
                    b_count <= 0;
                    stateA <= A_IDLE;
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
                    // Transition to COUNT when measure_A becomes 1
                    if (measure_A) begin
                        stateB <= B_COUNT;
                    end
                    else begin
                        stateB <= B_IDLE;
                    end
                end
                B_COUNT: begin
                    // Capture a_count and transition to B_DONE when periodA is measured
                    if (measure_A) begin
                        a_count <= a_count + 1;
                    end
                    else begin
                        stateB <= B_IDLE;
                    end
                    if (a_count >= periodA) begin
                        stateB <= B_DONE;
                        periodB <= a_count;
                    end
                end
                B_DONE: begin
                    // Reset counters and state
                    a_count <= 0;
                    stateB <= B_IDLE;
                end
                default: stateB <= B_IDLE;
            endcase
        end
    end

    // In B-domain, if measure_B=1, increment b_count on each B rising edge
    always @(posedge clk_B or negedge rst_n) begin
        if (!rst_n) begin
            b_count <= 0;
        end else if (measure_B) begin
            b_count <= b_count + 1;
        end
    end

    // In A-domain, if measure_A=1, increment a_count on each A rising edge
    always @(posedge clk_A or negedge rst_n) begin
        if (!rst_n) begin
            a_count <= 0;
        end else if (measure_A) begin
            a_count <= a_count + 1;
        end
    end

    // Combine results
    always @(*) begin
        if (!rst_n) begin
            valid = 0;
            A_faster_than_B = 0;
        end else begin
            valid = (done_A && done_B);
            if (valid) begin
                // Compare periodA and periodB
                if (periodA > periodB) begin
                    A_faster_than_B = 1;
                end else begin
                    A_faster_than_B = 0;
                end
            end else begin
                A_faster_than_B = 0;
            end
        end
    end

endmodule
