module gcd_top (#(parameter WIDTH = 4))(
    input clk,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input go,
    output [WIDTH-1:0] OUT,
    output logic done
);

    localparam WIDTH = 4;

    logic current_state;
    logic next_state;

    // State encoding
    localparam S0 = 2'd0;
    localparam S1 = 2'd1;
    localparam S2 = 2'd2;
    localparam S3 = 2'd3;

    // State transitions
    always_ff @(posedge clk) begin
        if (rst) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        case (current_state)
            S0: begin
                if (go)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                equal   = A == B;
                greater_than = A > B;
                if (equal)
                    next_state = S1;
                else if (greater_than)
                    next_state = S2;
                else
                    next_state = S3;
            end
            S2: begin
                if (A >= B)
                    A <= A - B;
                next_state = S2;
            end
            S3: begin
                if (!equal && !greater_than)
                    B <= B - A;
                next_state = S3;
            end
            default:
                current_state <= S0;
            end
        endcase
    end

    // GCD output is simply the difference (Euclidean step)
    assign OUT = A ^ B;

    // Done when no further computation is needed
    assign done = curr_state == S1;

endmodule
