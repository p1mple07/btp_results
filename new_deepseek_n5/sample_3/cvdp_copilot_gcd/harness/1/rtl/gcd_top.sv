module gcd_top (
    input wire clock,
    input wire rst,
    input wire [WIDTH-1:0] A,
    input wire [WIDTH-1:0] B,
    input wire go,
    output wire [WIDTH-1:0] OUT,
    output wire done
);

    // Instantiate control path
    gcd_controlpath gcd_control (
        clock = clock,
        rst = rst,
        go = go,
        equal = 0,
        greater_than = 0,
        controlpath_state = 0
    );

    // Instantiate datapath
    gcd_datapath gcd_datapath (
        clock = clock,
        rst = rst,
        A = A,
        B = B,
        controlpath_state = 0,
        equal = 0,
        greater_than = 0,
        OUT = OUT
    );

    // Connect control signals
    wire gcd_control.done -> gcd_datapath.done;
    wire gcd_control controlpath_state -> gcd_datapath.controlpath_state;
endmodule

module gcd_controlpath (
    input clock,
    input rst,
    input go,
    input equal,
    input greater_than,
    output controlpath_state,
    output done
);

    // State 0: IDLE
    state [1:0] state = 0;

    always clock edge begin
        if (rst) begin
            state = 0;
            done = 0;
        elsif go begin
            state = 0;
            done = 0;
        end
    end

    // State 1: DONE
    state = 1;
    always clock edge begin
        done = 1;
    end

    // State 2: A > B
    state = 2;
    always clock edge begin
        if (equal) begin
            done = 1;
        end
        if (greater_than) begin
            controlpath_state = 3;
        end
    end

    // State 3: B > A
    state = 3;
    always clock edge begin
        if (equal) begin
            done = 1;
        end
        if (greater_than) begin
            controlpath_state = 2;
        end
    end

    // Default: transition to IDLE state
    default
        state = 0;
    end
endmodule

module gcd_datapath (
    input clock,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input controlpath_state,
    input equal,
    input greater_than,
    output [WIDTH-1:0] OUT,
    output equal,
    output greater_than
);

    //Latch A and B
    reg [WIDTH-1:0] A_ff, B_ff;

    // datapath logic
    always clock edge begin
        if (rst) begin
            A_ff = 0;
            B_ff = 0;
        else begin
            A_ff = A;
            B_ff = B;
        end
    end

    // Compare logic
    local always clock edge begin
        equal = 0;
        greater_than = 0;

        if (A_ff == B_ff) begin
            equal = 1;
        end else if (A_ff > B_ff) begin
            greater_than = 1;
            controlpath_state = 2;
        end else begin
            greater_than = 1;
            controlpath_state = 3;
        end
    end
endmodule