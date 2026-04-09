Module: gcd_top
//------------------------------------------------------------------------------
module gcd_top #(parameter WIDTH = 4) (
    input  clk,
    input  rst,
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  go,
    output [WIDTH-1:0] OUT,
    output done
);

    // Internal wires connecting control and datapath modules
    wire [1:0] control_state;
    wire       dp_equal;
    wire       dp_greater_than;

    // Instantiate GCD Control Path Module
    gcd_controlpath #(WIDTH) control_inst (
        .clk(clk),
        .rst(rst),
        .go(go),
        .equal(dp_equal),
        .greater_than(dp_greater_than),
        .controlpath_state(control_state),
        .done(done)
    );

    // Instantiate GCD Datapath Module
    gcd_datapath #(WIDTH) datapath_inst (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .controlpath_state(control_state),
        .OUT(OUT),
        .equal(dp_equal),
        .greater_than(dp_greater_than)
    );

endmodule

//------------------------------------------------------------------------------
// Module: gcd_controlpath
//------------------------------------------------------------------------------
module gcd_controlpath #(parameter WIDTH = 4) (
    input  clk,
    input  rst,
    input  go,
    input  equal,
    input  greater_than,
    output reg [1:0] controlpath_state,
    output reg       done
);

    // FSM state encoding:
    // S0 (IDLE):  2'b00
    // S1 (DONE):  2'b01
    // S2 (A > B): 2'b10
    // S3 (B > A): 2'b11
    reg [1:0] state, next_state;

    // Sequential logic for state register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= 2'b00; // S0: IDLE
        else
            state <= next_state;
    end

    // Combinational logic for next state
    always_comb begin
        // Default next state is S0 (IDLE)
        next_state = 2'b00;
        case (state)
            2'b00: begin // S0: IDLE
                if (go) begin
                    if (equal)
                        next_state = 2'b01; // S1: DONE
                    else if (greater_than)
                        next_state = 2'b10; // S2: A > B
                    else
                        next_state = 2'b11; // S3: B > A
                end
            end
            2'b01: begin // S1: DONE
                next_state = 2'b00; // Return to IDLE
            end
            2'b10: begin // S2: A > B
                next_state = 2'b00;
            end
            2'b11: begin // S3: B > A
                next_state = 2'b00;
            end
            default: next_state = 2'b00;
        endcase
    end

    // Output current state and done signal
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            controlpath_state <= 2'b00;
            done <= 1'b0;
        end else begin
            controlpath_state <= state;
            done <= (state == 2'b01);
        end
    end

endmodule

//------------------------------------------------------------------------------
// Module: gcd_datapath
//------------------------------------------------------------------------------
module gcd_datapath #(parameter WIDTH = 4) (
    input  clk,
    input  rst,
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [1:0] controlpath_state,
    output reg [WIDTH-1:0] OUT,
    output reg       equal,
    output reg       greater_than
);

    // Internal registers to hold intermediate values
    reg [WIDTH-1:0] A_ff;
    reg [WIDTH-1:0] B_ff;

    // Sequential logic for datapath operations
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            A_ff      <= {WIDTH{1'b0}};
            B_ff      <= {WIDTH{1'b0}};
            OUT       <= {WIDTH{1'b0}};
            equal     <= 1'b0;
            greater_than <= 1'b0;
        end else begin
            case (controlpath_state)
                2'b00: begin // S0: Latch inputs and compare fresh values
                    A_ff      <= A;
                    B_ff      <= B;
                    equal     <= (A == B);
                    greater_than <= (A > B);
                end
                2'b10: begin // S2: A > B: subtract B from A
                    A_ff      <= A_ff - B_ff;
                    equal     <= (A_ff == B_ff);
                    greater_than <= (A_ff > B_ff);
                end
                2'b11: begin // S3: B > A: subtract A from B
                    B_ff      <= B_ff - A_ff;
                    equal     <= (A_ff == B_ff);
                    greater_than <= (A_ff > B_ff);
                end
                2'b01: begin // S1: DONE: output result (A_ff equals B_ff)
                    OUT       <= A_ff;
                    equal     <= 1'b1;
                    greater_than <= 1'b0;
                end
                default: begin // Default behavior: latch inputs
                    A_ff      <= A;
                    B_ff      <= B;
                    equal     <= (A == B);
                    greater_than <= (A > B);
                end
            endcase
        end
    end

endmodule