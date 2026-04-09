module gcd_top #(parameter WIDTH = 16) (
    input clk,
    input rst,
    input go,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output reg [WIDTH-1:0] OUT,
    output reg done
);

    wire [WIDTH-1:0] A_ff, B_ff;
    wire [1:0] controlpath_state;
    wire equal, greater_than;

    // Instantiate control path
    gcd_controlpath ctrl_path(
        .clk(clk),
        .rst(rst),
        .go(go),
        .equal(equal),
        .greater_than(greater_than),
        .controlpath_state(controlpath_state),
        .done(done),
        .WIDTH(WIDTH)
    );

    // Instantiate datapath
    gcd_datapath datapath(
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .controlpath_state(controlpath_state),
        .OUT(OUT),
        .equal(equal),
        .greater_than(greater_than),
        .WIDTH(WIDTH)
    );

    // Reset logic
    initial begin
        if (rst) begin
            OUT = 0;
            done = 0;
            A_ff = 0;
            B_ff = 0;
        end else begin
            if (go) begin
                A_ff = A;
                B_ff = B;
                done = 0;
            end
        end
    end

endmodule
