module gcd_top(
    input clk,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input go,
    output reg done
);

    parameter WIDTH = 16;

    wire [WIDTH-1:0] A_ff, B_ff;
    wire [WIDTH-1:0] equal, greater_than;

    gcd_controlpath ctrl_path(
        .clk(clk),
        .rst(rst),
        .A(A_ff),
        .B(B_ff),
        .go(go),
        .equal(equal),
        .greater_than(greater_than),
        .done(done)
    );

    gcd_datapath datapath(
        .clk(clk),
        .rst(rst),
        .A(A_ff),
        .B(B_ff),
        .controlpath_state(ctrl_path.controlpath_state),
        .OUT(OUT),
        .equal(equal),
        .greater_than(greater_than)
    );

    initial begin
        done <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_ff <= 0;
            B_ff <= 0;
        end else begin
            if (go) begin
                A_ff <= A;
                B_ff <= B;
                go <= 0;
                done <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (done) begin
            OUT <= datapath.OUT;
            done <= 0;
        end
    end
endmodule
 module gcd_top(
    input clk,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input go,
    output reg done
);

    parameter WIDTH = 16;

    wire [WIDTH-1:0] A_ff, B_ff;
    wire [WIDTH-1:0] equal, greater_than;

    gcd_controlpath ctrl_path(
        .clk(clk),
        .rst(rst),
        .A(A_ff),
        .B(B_ff),
        .go(go),
        .equal(equal),
        .greater_than(greater_than),
        .done(done)
    );

    gcd_datapath datapath(
        .clk(clk),
        .rst(rst),
        .A(A_ff),
        .B(B_ff),
        .controlpath_state(ctrl_path.controlpath_state),
        .OUT(OUT),
        .equal(equal),
        .greater_than(greater_than)
    );

    initial begin
        done <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_ff <= 0;
            B_ff <= 0;
        end else begin
            if (go) begin
                A_ff <= A;
                B_ff <= B;
                go <= 0;
                done <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (done) begin
            OUT <= datapath.OUT;
            done <= 0;
        end
    end
endmodule