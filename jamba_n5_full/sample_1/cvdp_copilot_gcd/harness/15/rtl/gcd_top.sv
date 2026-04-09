module lcm_3_ip #(
    parameter WIDTH = 4
) (
    input                     clk,
    input                     rst,
    input  [WIDTH-1:0]      A,
    input  [WIDTH-1:0]      B,
    input  [WIDTH-1:0]      C,
    input                     go,
    output logic  [3 * WIDTH-1:0] OUT,
    output logic           done
);

    logic [WIDTH-1:0] gcd1;
    logic [WIDTH-1:0] gcd2;

    gcd_top #(.WIDTH(WIDTH)) uut1 (.A(A), .B(B), .go(go));
    assign gcd1 = uut1.OUT;

    gcd_top #(.WIDTH(WIDTH)) uut2 (.A(B), .B(C), .go(go));
    assign gcd2 = uut2.OUT;

    assign OUT = (A * B * C) / gcd2;

    assign done = 1'b1;

    always_ff @(posedge clk) begin
        if (~done) begin
            done <= 1'b0;
        end
    end

endmodule
