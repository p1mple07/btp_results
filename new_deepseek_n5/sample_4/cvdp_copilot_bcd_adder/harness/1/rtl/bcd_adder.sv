module bcd_adder( input  [3:0] a,           // 4'b0000
                 input  [3:0] b,           // 4'b0000
                 output [3:0] sum,         // The corrected 4-bit BCD result
                 output       cout           // Carry when result exceeds BCD range (i.e., when the result is > 9)
                );

    // Instantiate the Binary Adder
    four_bit_adder adder1(a, b, 1'b0, sum, binary_cout);

    // Instantiate the Logic Block
    four_bit_adder adder2(sum, 6, binary_cout, sum, carry);

    // Instantiate the BCD Correction
    four_bit_adder adder3(sum, 6, carry, sum, cout);
endmodule