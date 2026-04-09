module gcd_top #(parameter WIDTH = 16) (
    input clk,
    input rst,
    input go,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output reg [WIDTH-1:0] OUT,
    output reg done
);

    // Instantiate control path
    gcd_controlpath ctl_path (
        .clk(clk),
        .rst(rst),
        .go(go),
        .equal(ctl_eq),
        .greater_than(ctl_gt),
        .controlpath_state(ctl_state)
    );

    // Instantiate datapath
    gcd_datapath datapath (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .controlpath_state(ctl_state),
        .OUT(OUT),
        .equal(ctl_eq),
        .greater_than(ctl_gt)
    );

    // Connect signals
    assign ctl_eq = (A == B) ? 1'b1 : 1'b0;
    assign ctl_gt = (A > B) ? 1'b1 : 1'b0;

    // Reset logic
    initial begin
        if (rst) begin
            A <= 16'b0;
            B <= 16'b0;
            OUT <= 16'b0;
            done <= 1'b0;
        end
    end

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ctl_state <= 2'b00;
        end else begin
            case (ctl_state)
                2'b00: begin
                    if (go) begin
                        ctl_state <= 2'b01;
                    end
                end
                2'b01: begin
                    if (ctl_eq) begin
                        OUT <= A;
                        done <= 1'b1;
                        ctl_state <= 2'b00;
                    end
                end
                default: begin
                    ctl_state <= 2'b00;
                end
            endcase
        end
    end

endmodule
