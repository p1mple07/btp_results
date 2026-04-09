module gcd_top(
    parameter WIDTH,
    input clock,
    input rst,
    input go,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output [WIDTH-1:0] OUT,
    output done
);

    // Instantiate control path
    gcd_controlpath gcd_controlpath (
        .clk(clock),
        .rst(rst),
        .go(go),
        .equal(),
        .greater_than(),
        .controlpath_state(0)
    );

    // Instantiate datapath
    gcd_datapath gcd_datapath (
        .clk(clock),
        .rst(rst),
        .A(A),
        .B(B),
        .controlpath_state(0),
        .OUT(0),
        .equal(),
        .greater_than()
    );

    // Connect the outputs
    done = gcd_controlpath.done;
    OUT = gcd_datapath.OUT;
endmodule

module gcd_controlpath (
    input clock,
    input rst,
    input go,
    input equal,
    input greater_than,
    output controlpath_state [1:0],
    output done
);

    // State 0: IDLE
    always clock positive edge: 
        if (rst) 
            controlpath_state = 0;
        else if (go) 
            controlpath_state = 1;
            done = 0;
        end
endmodule

module gcd_datapath (
    input clock,
    input rst,
    input A,
    input B,
    input controlpath_state [1:0],
    output OUT [WIDTH-1:0],
    output equal,
    output greater_than
);

    //Latch inputs
    reg A_ff, B_ff;
    always clock positive edge:
        A_ff = A;
        B_ff = B;
    end

    // State 0: Initial loading
    always clock positive edge:
        if (rst) 
            A_ff = 0;
            B_ff = 0;
            controlpath_state = 0;
            done = 0;
        else if (controlpath_state[1] & ~controlpath_state[0]) 
            // Transition based on comparisons
            if (A_ff > B_ff) 
                controlpath_state = 2;
                greater_than = 1;
                equal = 0;
            else if (B_ff > A_ff) 
                controlpath_state = 3;
                equal = 1;
                greater_than = 0;
            else 
                controlpath_state = 1;
                done = 1;
            end
        end
    end

    // Perform subtraction
    always clock positive edge:
        if (controlpath_state == 1) 
            if (A_ff > B_ff) 
                A_ff = A_ff - B_ff;
            else 
                B_ff = B_ff - A_ff;
            end
        end
    end

    // Final output
    always clock positive edge:
        if (controlpath_state == 1) 
            OUT = A_ff;
        end
    end
endmodule