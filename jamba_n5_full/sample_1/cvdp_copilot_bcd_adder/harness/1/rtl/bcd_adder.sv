module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule

module four_bit_adder (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout
);

    wire [2:0] carry;

    generate
        for (integer i = 0; i < 4; i = i + 1) begin : FA_inst
            full_adder u$add (
                .a(a[i]),
                .b(b[i]),
                .cin(cin),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    assign sum = sum[3];
    assign cout = carry[3];

endmodule

module bcd_adder (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] sum,
    output       cout
);

    wire [3:0] binary_sum;
    wire binary_cout;
    wire [3:0] temp_sum;
    wire carry;

    four_bit_adder adder1 (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(binary_sum),
        .cout(binary_cout)
    );

    assign temp_sum = binary_sum;
    assign carry = binary_cout;

    if (temp_sum[3:0] >= 4'd10) begin
        sum = {temp_sum[3:0] - 16, 1'b0};
        cout = 1;
    else
        sum = temp_sum;
        cout = 0;
    end

endmodule
