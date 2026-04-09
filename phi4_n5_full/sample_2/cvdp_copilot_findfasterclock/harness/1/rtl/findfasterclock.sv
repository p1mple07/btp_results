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

    // Clock A FSM: Measures periodA (number of clk_B pulses during one clk_A cycle)
    always @(posedge clk_A or negedge rst_n) begin
        if (!rst_n) begin
            stateA      <= A_IDLE;
            measure_B   <= 0;
            b_count     <= 0;
            periodA     <= 0;
            done_A      <= 0;
        end else begin
            case (stateA)
                A_IDLE: begin
                    // Initialize counter and enable measurement in B-domain
                    measure_B  <= 1;
                    b_count    <= 0;
                    periodA    <= 0;
                    done_A     <= 0;
                    stateA     <= A_COUNT;
                end
                A_COUNT: begin
                    // Capture the number of clk_B pulses counted during this clk_A cycle
                    periodA    <= b_count;
                    done_A     <= 1;
                    stateA     <= A_DONE;
                end
                A_DONE: begin
                    // Remain in DONE state (measurement complete)
                    stateA     <= A_DONE;
                end
                default: stateA <= A_IDLE;
            endcase
        end
    end

    // Clock B FSM: Measures periodB (number of clk_A pulses during one clk_B cycle)
    always @(posedge clk_B or negedge rst_n) begin
        if (!rst_n) begin
            stateB      <= B_IDLE;
            measure_A   <= 0;
            a_count     <= 0;
            periodB     <= 0;
            done_B      <= 0;
        end else begin
            case (stateB)
                B_IDLE: begin
                    // Initialize counter and enable measurement in A-domain
                    measure_A  <= 1;
                    a_count    <= 0;
                    periodB    <= 0;
                    done_B     <= 0;
                    stateB     <= B_COUNT;
                end
                B_COUNT: begin
                    // Capture the number of clk_A pulses counted during this clk_B cycle
                    periodB    <= a_count;
                    done_B     <= 1;
                    stateB     <= B_DONE;
                end
                B_DONE: begin
                    // Remain in DONE state (measurement complete)
                    stateB     <= B_DONE;
                end
                default: stateB <= B_IDLE;
            endcase
        end
    end

    // In B-domain: Increment b_count on each rising edge of clk_B when measurement is enabled
    always @(posedge clk_B or negedge rst_n) begin
        if (!rst_n) begin
            b_count <= 0;
        end else if (measure_B) begin
            b_count <= b_count + 1;
        end
    end

    // In A-domain: Increment a_count on each rising edge of clk_A when measurement is enabled
    always @(posedge clk_A or negedge rst_n) begin
        if (!rst_n) begin
            a_count <= 0;
        end else if (measure_A) begin
            a_count <= a_count + 1;
        end
    end

    // Combine results:
    // valid is high when both measurements are complete.
    // Compare periodA and periodB: if periodB > periodA, then clk_A is faster.
    always @(*) begin
        if (!rst_n) begin
            valid            = 0;
            A_faster_than_B = 0;
        end else begin
            valid = (done_A && done_B);
            if (valid) begin
                A_faster_than_B = (periodB > periodA) ? 1'b1 : 1'b0;
            end else begin
                A_faster_than_B = 1'b0;
            end
        end
    end

endmodule