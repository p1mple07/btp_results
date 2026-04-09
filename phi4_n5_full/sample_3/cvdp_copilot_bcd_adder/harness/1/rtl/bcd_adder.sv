Module
module bcd_adder(
    input  [3:0] a,             // 4-bit BCD input
    input  [3:0] b,             // 4-bit BCD input
    output [3:0] sum,           // Corrected 4-bit BCD result
    output       cout           // Carry-out indicating overflow beyond BCD range
);
    // Intermediate signals from the binary adder
    wire [3:0] binary_sum;
    wire       binary_cout;
    // Correction signal: true if binary_sum >= 10 (i.e. > 9)
    wire       correction;
    // Signals from the correction adder (adding 6)
    wire [3:0] sum_corr;
    wire       corr_cout;

    // Binary Adder Block: add the two 4-bit inputs
    four_bit_adder adder1(
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(binary_sum),
        .cout(binary_cout)
    );

    // Correction Logic Block:
    // If the intermediate binary sum is 10 (1010) or greater, correction is needed.
    assign correction = (binary_sum >= 4'd10);

    // BCD Correction Block: add 6 (0110) if correction is required.
    // The constant is formed using the correction signal:
    // When correction==1, {1'b0, correction, correction, 1'b0} becomes 4'b0110.
    // When correction==0, it becomes 4'b0000.
    four_bit_adder adder2(
        .a(binary_sum),
        .b({1'b0, correction, correction, 1'b0}),
        .cin(1'b0),
        .sum(sum_corr),
        .cout(corr_cout)
    );

    // Final Output Selection:
    // If correction is needed, use the corrected sum and its carry;
    // otherwise, pass through the binary adder's result.
    assign sum  = (correction) ? sum_corr : binary_sum;
    assign cout = (correction) ? corr_cout : binary_cout;
endmodule


// Four-Bit Adder Module using Full Adders
module four_bit_adder(
    input  [3:0] a,           // 4-bit input a
    input  [3:0] b,           // 4-bit input b
    input        cin,         // Carry input
    output [3:0] sum,         // 4-bit sum output
    output       cout         // Final carry output
);
    // Internal carry wires for each bit position
    wire [3:0] carry;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_full_adder
            if (i == 0) begin
                full_adder fa (
                    .a(a[0]),
                    .b(b[0]),
                    .cin(cin),
                    .sum(sum[0]),
                    .cout(carry[0])
                );
            end else begin
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i-1]),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate
    // The final carry-out is taken from the last full adder stage
    assign cout = carry[3];
endmodule


// Full Adder Module
module full_adder(
    input  a,      // First addend input
    input  b,      // Second addend input
    input  cin,    // Carry input
    output sum,    // Sum output
    output cout    // Carry output
);
    assign sum  = a ^ b ^ cin;                      // Sum is the XOR of inputs
    assign cout = (a & b) | (a & cin) | (b & cin);     // Carry is generated if any two inputs are high
endmodule