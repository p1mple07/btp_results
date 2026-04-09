module gcd_controlpath #(parameter WIDTH = 4) (
    input  logic         clk,
    input  logic         rst,
    input  logic         go,
    input  logic         equal,
    input  logic         greater_than,
    output logic [1:0]   controlpath_state,
    output logic         done
);

    // Define FSM states
    typedef enum logic [1:0] {
        S0_IDLE     = 2'b00,
        S1_DONE     = 2'b01,
        S2_A_GREATER= 2'b10,
        S3_B_GREATER= 2'b11
    } state_t;

    state_t current_state, next_state;

    // State register update
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S0_IDLE;
        else
            current_state <= next_state;
    end

    // Next state combinational logic
    always_comb begin
        next_state = current_state; // default hold state
        case (current_state)
            S0_IDLE: begin
                if (go) begin
                    if (equal)
                        next_state = S1_DONE;
                    else if (greater_than)
                        next_state = S2_A_GREATER;
                    else
                        next_state = S3_B_GREATER;
                end
            end
            S1_DONE: begin
                next_state = S0_IDLE;
            end
            S2_A_GREATER: begin
                next_state = S0_IDLE;
            end
            S3_B_GREATER: begin
                next_state = S0_IDLE;
            end
            default: next_state = S0_IDLE;
        endcase
    end

    // Output assignments: drive controlpath_state and done signal
    always_ff @(posedge clk) begin
        if (rst) begin
            controlpath_state <= S0_IDLE;
            done              <= 1'b0;
        end else begin
            controlpath_state <= current_state;
            // Assert done only in S1_DONE state for one clock cycle
            if (current_state == S1_DONE)
                done <= 1'b1;
            else
                done <= 1'b0;
        end
    end

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

    // Internal registers to hold values
    logic [WIDTH-1:0] A_ff, B_ff;

    // Datapath sequential logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            A_ff <= {WIDTH{1'b0}};
            B_ff <= {WIDTH{1'b0}};
            OUT  <= {WIDTH{1'b0}};
        end else begin
            case (controlpath_state)
                2'b00: begin // S0_IDLE: Latch input values
                    A_ff <= A;
                    B_ff <= B;
                    // OUT remains unchanged in idle state
                end
                2'b01: begin // S1_DONE: Output result (A_ff equals B_ff)
                    OUT <= A_ff;
                end
                2'b10: begin // S2_A_GREATER: Subtract B_ff from A_ff
                    A_ff <= A_ff - B_ff;
                end
                2'b11: begin // S3_B_GREATER: Subtract A_ff from B_ff
                    B_ff <= B_ff - A_ff;
                end
                default: ; // No operation
            endcase
        end
    end

    // Combinational logic for comparison outputs
    assign equal       = (A_ff == B_ff);
    assign greater_than= (A_ff >  B_ff);

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

    // Internal wires for inter-module connections
    logic [1:0] control_state;
    logic       equal, greater_than;

    // Instantiate the control path module
    gcd_controlpath #(WIDTH) control_inst (
        .clk            (clk),
        .rst            (rst),
        .go             (go),
        .equal          (equal),
        .greater_than   (greater_than),
        .controlpath_state(control_state),
        .done           (done)
    );

    // Instantiate the datapath module
    gcd_datapath #(WIDTH) datapath_inst (
        .clk            (clk),
        .rst            (rst),
        .A              (A),
        .B              (B),
        .controlpath_state(control_state),
        .OUT            (OUT),
        .equal          (equal),
        .greater_than   (greater_than)
    );

endmodule