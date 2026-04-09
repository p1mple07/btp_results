module bcd_adder(
    input  [3:0] a,             // 4-bit BCD input
    input  [3:0] b,             // 4-bit BCD input
    output [3:0] sum,           // The corrected 4-bit BCD result of the addition
    output       cout           // Carry-out to indicate overflow beyond BCD range
);

    // Intermediate signals from the binary adder
    wire [3:0] binary_sum;       // Intermediate binary sum
    wire       binary_cout;      // Intermediate binary carry

    // Correction logic signals
    wire       correction;       // 1 if binary_sum > 9, else 0
    wire [3:0] corr_val;         // 6 if correction is needed, else 0

    // Instantiate the first four-bit adder for Binary Addition
    four_bit_adder adder1(
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(binary_sum),
        .cout(binary_cout)
    );

    // Determine if BCD correction is needed:
    // If binary_sum is 10 or greater, correction is required.
    assign correction = (binary_sum >= 4'd10) ? 1'b1 : 1'b0;
    // If correction is needed, add 6 (0110); otherwise add 0.
    assign corr_val = (correction) ? 4'd6 : 4'd0;

    // Instantiate the second four-bit adder for BCD correction
    // This adder adds the correction value (6) to the binary sum if needed.
    four_bit_adder adder2(
        .a(binary_sum),
        .b(corr_val),
        .cin(1'b0),
        .sum(sum),
        .cout()  // The carry from this adder is not used.
    );

    // Set the final carry-out:
    // If correction was applied (i.e. binary sum > 9), cout is set to 1.
    // Otherwise, cout is 0.
    assign cout = correction;

endmodule


// Module of four_bit_adder
module four_bit_adder(
    input  [3:0] a,             // 4-bit input a
    input  [3:0] b,             // 4-bit input b
    input        cin,           // Carry input
    output [3:0] sum,           // 4-bit sum output
    output       cout           // Carry output
);

    genvar i;
    wire [3:0] carry;            // Internal carry wires for each bit

    generate
        for(i = 0; i < 4; i = i + 1) begin : adder_loop
            if(i == 0) begin
                full_adder fa(
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end else begin
                full_adder fa(
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i-1]),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate

    assign cout = carry[3];

endmodule


// Module of full_adder
module full_adder(
    input  a,      // First Addend input
    input  b,      // Second Addend input
    input  cin,    // Carry input
    output sum,    // Sum output
    output cout    // Carry output
);
                  
    assign sum = a ^ b ^ cin;                      // Calculate sum using XOR
    assign cout = (a & b) | (b & cin) | (a & cin);   // Calculate carry-out
endmodule