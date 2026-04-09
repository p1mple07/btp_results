module
module gcd_top(
    input clock,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output [WIDTH-1:0] OUT,
    output done
);

    // Instantiate control path
    gcd_controlpath gcd_control;
    
    // Instantiate datapath
    gcd_datapath gcd_datapath;

    // Connect inputs and outputs
    wire
        rst -> gcd_control.rst,
        rst -> gcd_datapath.rst,
        A -> gcd_datapath.A,
        B -> gcd_datapath.B,
        go -> gcd_control.go,
        gcd_control.state -> gcd_datapath.state,
        gcd_datapath.done -> gcd_control.done,
        gcd_datapath.equal, gcd_datapath.greater_than -> gcd_control.equal, gcd_control.greater_than,
        gcd_control.done -> done,
        done -> OUT;
endmodule

// Control path module
module gcd_controlpath(
    input clock,
    input rst,
    input go,
    input equal,
    input greater_than,
    output [1:0] state,
    output done
);

    // Initial state
    reg state = 0;
    reg done = 0;

    // Control path FSM
    always clocked (
        rising_edge clock,
        rst
    ) begin
        case (state)
            0: 
                if (go)
                    state = 1;
                else
                    state = 0;
            1: 
                if (equal)
                    state = 0;
                    done = 1;
                else if (greater_than)
                    state = 2;
                else
                    state = 0;
            2: 
                state = 0;
            3: 
                state = 0;
            default: 
                state = 0;
        endcase
    end

    // Output done signal
    always clocked (
        rising_edge clock,
        rst
    ) begin
        if (state == 1 && !rst)
            done = 1;
        else if (rst)
            done = 0;
        end
    end
endmodule

// Datapath module
module gcd_datapath(
    input clock,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input [1:0] state,
    output [WIDTH-1:0] OUT,
    output equal, greater_than
);

    // Internal registers
    reg A_ff = A;
    reg B_ff = B;
    reg done ff = 0;
    reg equal ff = 0;
    reg greater_than ff = 0;

    // Datapath logic
    always clocked (
        rising_edge clock,
        rst
    ) begin
        if (rst) begin
            A_ff = 0;
            B_ff = 0;
            done ff = 0;
            equal ff = 0;
            greater_than ff = 0;
            OUT = 0;
            state = 0;
            done = 0;
            return;
        end

        //Latch inputs
        A_ff = A;
        B_ff = B;

        // Generate control signals
        equal ff = (A_ff == B_ff);
        greater_than ff = (A_ff > B_ff);

        // Perform subtraction based on state
        case (state)
            0: 
                // No operation
                done ff = 0;
            1: 
                // Computed done
                done ff = 1;
                // Update result
                OUT = A_ff;
            2: 
                // Subtract B from A
                A_ff = A_ff - B_ff;
                done ff = 0;
            3: 
                // Subtract A from B
                B_ff = B_ff - A_ff;
                done ff = 0;
            default: 
                done ff = 0;
        endcase

        // Update state
        state = state + 1;
        state = state & 0b11;
    end

    // Output done signal
    always clocked (
        rising_edge clock,
        rst
    ) begin
        if (rst)
            done = 0;
        else
            done = done ff;
        end
    end

    // Output equal signal
    wire equal = equal ff;
    // Output greater_than signal
    wire greater_than = greater_than ff;
endmodule