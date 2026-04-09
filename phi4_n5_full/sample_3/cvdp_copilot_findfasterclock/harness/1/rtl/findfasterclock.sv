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

    //--------------------------------------------------
    // Clock A domain: Measure periodA (number of clk_B pulses)
    //--------------------------------------------------
    always @(posedge clk_A or negedge rst_n) begin
        if (!rst_n) begin
            stateA       <= A_IDLE;
            measure_B    <= 0;
            periodA      <= 0;
            done_A       <= 0;
        end else begin
            case (stateA)
                A_IDLE: begin
                    // Start measurement: assert measure_B so that b_count (in B-domain)
                    // increments on every rising edge of clk_B.
                    measure_B <= 1;
                    // Transition to COUNT state to capture the measured count.
                    stateA    <= A_COUNT;
                end
                A_COUNT: begin
                    // Capture the current b_count value as periodA.
                    periodA   <= b_count;
                    done_A    <= 1;
                    // Transition to DONE state.
                    stateA    <= A_DONE;
                end
                A_DONE: begin
                    // Remain in DONE state until reset.
                    stateA    <= A_DONE;
                end
                default: stateA <= A_IDLE;
            endcase
        end
    end

    //--------------------------------------------------
    // Clock B domain: Measure periodB (number of clk_A pulses)
    //--------------------------------------------------
    always @(posedge clk_B or negedge rst_n) begin
        if (!rst_n) begin
            stateB       <= B_IDLE;
            measure_A    <= 0;
            periodB      <= 0;
            done_B       <= 0;
        end else begin
            case (stateB)
                B_IDLE: begin
                    // Start measurement: assert measure_A so that a_count (in A-domain)
                    // increments on every rising edge of clk_A.
                    measure_A <= 1;
                    // Transition to COUNT state to capture the measured count.
                    stateB    <= B_COUNT;
                end
                B_COUNT: begin
                    // Capture the current a_count value as periodB.
                    periodB   <= a_count;
                    done_B    <= 1;
                    // Transition to DONE state.
                    stateB    <= B_DONE;
                end
                B_DONE: begin
                    // Remain in DONE state until reset.
                    stateB    <= B_DONE;
                end
                default: stateB <= B_IDLE;
            endcase
        end
    end

    //--------------------------------------------------
    // B-domain counter: Increment b_count when measure_B is asserted.
    //--------------------------------------------------
    always @(posedge clk_B or negedge rst_n) begin
        if (!rst_n) begin
            b_count <= 0;
        end else if (measure_B) begin
            b_count <= b_count + 1;
        end
    end

    //--------------------------------------------------
    // A-domain counter: Increment a_count when measure_A is asserted.
    //--------------------------------------------------
    always @(posedge clk_A or negedge rst_n) begin
        if (!rst_n) begin
            a_count <= 0;
        end else if (measure_A) begin
            a_count <= a_count + 1;
        end
    end

    //--------------------------------------------------
    // Output Logic:
    // valid is asserted when both measurements are complete.
    // If valid, compare periodA and periodB. If periodB > periodA,
    // then clk_A toggles faster, so A_faster_than_B is set to 1.
    //--------------------------------------------------
    always @(*) begin
        if (!rst_n) begin
            valid            = 0;
            A_faster_than_B = 0;
        end else begin
            valid = (done_A && done_B);
            if (valid)
                A_faster_than_B = (periodB > periodA);
            else
                A_faster_than_B = 0;
        end
    end

endmodule