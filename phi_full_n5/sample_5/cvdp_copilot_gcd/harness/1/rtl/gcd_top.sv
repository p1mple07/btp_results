module gcd_top #(parameter WIDTH = 16) (
    input clk,
    input rst,
    input go,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output reg [WIDTH-1:0] OUT,
    output reg done
);

    // Instantiate control path and datapath modules
    gcd_controlpath ctl_path (
        .clk(clk),
        .rst(rst),
        .go(go),
        .equal(done),
        .greater_than(ctl_datapath.greater_than),
        .controlpath_state(ctl_datapath.controlpath_state)
    );

    gcd_datapath datapath (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .controlpath_state(ctl_path.controlpath_state),
        .OUT(OUT),
        .equal(done),
        .greater_than(ctl_path.greater_than)
    );

    // Synchronize the go signal
    always @(posedge clk) begin
        if (rst) begin
            go <= 1'b0;
            OUT <= 0;
            done <= 1'b0;
        end else if (go) begin
            go <= 1'b0;
            OUT <= datapath.OUT;
            done <= 1'b1;
        end
    end

endmodule
