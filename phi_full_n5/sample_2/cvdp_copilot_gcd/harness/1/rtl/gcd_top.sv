module gcd_top(
    input wire clk,
    input wire rst,
    input wire go,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output reg [WIDTH-1:0] OUT,
    output reg done
);

    parameter WIDTH = 16;

    // Instantiate control path and datapath modules
    gcd_controlpath ctl_path(.clk(clk), .rst(rst), .go(go), .equal(equal), .greater_than(greater_than), .controlpath_state(ctl_state), .done(done));
    gcd_datapath datapath(.clk(clk), .rst(rst), .A(A), .B(B), .controlpath_state(ctl_state), .OUT(OUT), .equal(equal), .greater_than(greater_than));

    // Internal signals for control path
    reg [1:0] ctl_state = 2'b0;
    reg equal, greater_than;

    // State machine logic for control path
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ctl_state <= 2'b0;
            equal <= 1'b0;
            greater_than <= 1'b0;
            OUT <= 16'b0;
            done <= 1'b0;
        end else if (go) begin
            ctl_state <= ctl_state + 1;
            equal <= 1'b0;
            greater_than <= 1'b0;
            OUT <= 16'b0;
            done <= 1'b0;
        end else begin
            case (ctl_state)
                2'b0: begin
                    if (A == B) begin
                        equal <= 1'b1;
                        OUT <= A;
                        done <= 1'b1;
                    end
                    ctl_state <= 2'b1;
                end
                2'b1: begin
                    if (A > B) begin
                        greater_than <= 1'b1;
                        ctl_state <= 2'b2;
                    end
                    ctl_state <= 2'b1;
                end
                2'b2: begin
                    if (B > A) begin
                        greater_than <= 1'b1;
                        ctl_state <= 2'b3;
                    end
                    ctl_state <= 2'b1;
                end
                2'b3: begin
                    OUT <= A - B;
                    ctl_state <= 2'b1;
                end
                default: ctl_state <= 2'b0;
            endcase
        end
    end

endmodule
