module gcd_controlpath #(parameter WIDTH = 4) (
    input  logic         clk,
    input  logic         rst,
    input  logic         go,
    input  logic         equal,
    input  logic         greater_than,
    output logic [1:0]   controlpath_state,
    output logic         done
);
    // FSM state encoding
    typedef enum logic [1:0] {
        S0_IDLE    = 2'b00,
        S1_DONE    = 2'b01,
        S2_A_GT_B  = 2'b10,
        S3_B_GT_A  = 2'b11
    } state_t;

    state_t state, next_state;

    // FSM state register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0_IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (state)
            S0_IDLE: begin
                if (go) begin
                    if (equal)
                        next_state = S1_DONE;
                    else if (greater_than)
                        next_state = S2_A_GT_B;
                    else
                        next_state = S3_B_GT_A;
                end else begin
                    next_state = S0_IDLE;
                end
            end
            S1_DONE: begin
                next_state = S0_IDLE;
            end
            S2_A_GT_B: begin
                if (equal)
                    next_state = S1_DONE;
                else if (greater_than)
                    next_state = S2_A_GT_B;
                else
                    next_state = S3_B_GT_A;
            end
            S3_B_GT_A: begin
                if (equal)
                    next_state = S1_DONE;
                else if (greater_than)
                    next_state = S2_A_GT_B;
                else
                    next_state = S3_B_GT_A;
            end
            default: next_state = S0_IDLE;
        endcase
    end

    // Output assignments
    assign controlpath_state = state;
    assign done = (state == S1_DONE);

endmodule

module gcd_datapath #(parameter WIDTH = 4) (
    input  logic         clk,
    input  logic         rst,
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [1:0]   controlpath_state,
    output logic [WIDTH-1:0] OUT,
    output logic         equal,
    output logic         greater_than
);
    // Internal registers
    reg [WIDTH-1:0] A_ff, B_ff, OUT_reg;

    // FSM state encoding (should match control path)
    localparam S0_IDLE    = 2'b00;
    localparam S1_DONE    = 2'b01;
    localparam S2_A_GT_B  = 2'b10;
    localparam S3_B_GT_A  = 2'b11;

    // Update registers based on control state
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            A_ff    <= '0;
            B_ff    <= '0;
            OUT_reg <= '0;
        end else begin
            case (controlpath_state)
                S0_IDLE: begin
                    A_ff <= A;
                    B_ff <= B;
                end
                S2_A_GT_B: begin
                    A_ff <= A_ff - B_ff;
                end
                S3_B_GT_A: begin
                    B_ff <= B_ff - A_ff;
                end
                S1_DONE: begin
                    OUT_reg <= A_ff; // A_ff and B_ff are equal here
                end
                default: begin
                    // No operation
                end
            endcase
        end
    end

    // Generate equal and greater_than signals
    // In S0 state, compare inputs A and B; otherwise, compare registers A_ff and B_ff
    assign equal    = (controlpath_state == S0_IDLE) ? (A == B) : (A_ff == B_ff);
    assign greater_than = (controlpath_state == S0_IDLE) ? (A > B) : (A_ff > B_ff);

    // Assign output
    assign OUT = OUT_reg;

endmodule

module gcd_top #(parameter WIDTH = 4) (
    input  logic         clk,
    input  logic         rst,
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic         go,
    output logic [WIDTH-1:0] OUT,
    output logic         done
);

    // Wires to connect control and datapath modules
    wire [1:0] control_state;
    wire       dp_equal, dp_greater_than;
    wire [WIDTH-1:0] dp_OUT;

    // Instantiate control path
    gcd_controlpath #(WIDTH) u_control (
        .clk(clk),
        .rst(rst),
        .go(go),
        .equal(dp_equal),
        .greater_than(dp_greater_than),
        .controlpath_state(control_state),
        .done(done)
    );

    // Instantiate datapath
    gcd_datapath #(WIDTH) u_datapath (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .controlpath_state(control_state),
        .OUT(dp_OUT),
        .equal(dp_equal),
        .greater_than(dp_greater_than)
    );

    // Connect top-level output
    assign OUT = dp_OUT;

endmodule