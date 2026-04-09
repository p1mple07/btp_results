module lcm_3_ip #(
    parameter WIDTH = 4
) (
    input                         clk,
    input                         rst,
    input  [WIDTH-1:0]            A,
    input  [WIDTH-1:0]            B,
    input  [WIDTH-1:0]            C,
    input                         go,
    output logic [3*WIDTH-1:0] OUT,
    output logic                  done
);

    // Intermediate GCD calculations
    logic [WIDTH-1:0] x, y, z;
    logic [WIDTH-1:0] gcd_AB, gcd_BC, gcd_CA;

    gcd_top
    #(
        .WIDTH(WIDTH)
    ) gcd_AB_inst (
        .clk (clk),
        .rst (rst),
        .A (A),
        .B (B),
        .C (C),
        .go (go),
        .OUT (gcd_AB),
        .done (done_AB)
    );

    gcd_top
    #(
        .WIDTH(WIDTH)
    ) gcd_BC_inst (
        .clk (clk),
        .rst (rst),
        .A (B),
        .B (C),
        .C (A),
        .go (go),
        .OUT (gcd_BC),
        .done (done_BC)
    );

    gcd_top
    #(
        .WIDTH(WIDTH)
    ) gcd_CA_inst (
        .clk (clk),
        .rst (rst),
        .A (C),
        .B (A),
        .C (B),
        .go (go),
        .OUT (gcd_CA),
        .done (done_CA)
    );

    // Pairwise GCDs
    assign gcd_AB = gcd_AB_inst.OUT;
    assign gcd_BC = gcd_BC_inst.OUT;
    assign gcd_CA = gcd_CA_inst.OUT;

    // LCM formula
    assign OUT = (A * B * C) / (gcd_AB / gcd_BC / gcd_CA);

    // Completion flag
    always_comb begin
        done <= (rst || (done_AB && done_BC && done_CA));
    end

endmodule
