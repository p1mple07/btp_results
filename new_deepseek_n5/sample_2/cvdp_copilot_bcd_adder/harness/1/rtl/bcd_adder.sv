Module of four_bit_adder
module four_bit_adder(        
                      input [3:0] a,           // 4-bit input a
                      input [3:0] b,           // 4-bit input b
                      input cin,               // Carry input
                      output [3:0] sum,        // 4-bit sum output
                      output cout              // Carry output
                     );

    wire [2:0] carry;         // Intermediate carry wires

    genvar i;                 // Declare a variable for the generate loop

    generate
        
           // Instantiate full_adder for each bit position
           full_adder fulla(.a(a[i]), .b(b[i]), .cin(cin), .sum(sum[i]), .cout(carry[i]));
           // Assign carry for next bit
           assign carry[i+1] = carry[i] & (a[i] | b[i] | cin);

    endgenerate

    assign sum[3] = carry[3]; // Final sum bit
endmodule

// Module of bcd_adder
module bcd_adder(                
                 input  [3:0] a,             // 4-bit BCD input
                 input  [3:0] b,             // 4-bit BCD input
                 output [3:0] sum,           // The corrected 4-bit BCD result of the addition
                 output       cout           // Carry-out to indicate overflow beyond BCD range (i.e., when the result exceeds 9)
                );

    wire [3:0] binary_sum;         // Intermediate binary sum
    wire binary_cout;              // Intermediate binary carry
    wire z1, z2;                   // Intermediate wires for BCD correction
    wire carry;                    // Carry for the second adder

    // Instantiate the first four-bit adder for Binary Addition
    four_bit_adder adder1(         
                      .a(a),            
                      .b(b),            
                      .cin(1'b0),       
                      .sum(binary_sum), 
                      .cout(binary_cout) 
                     );

    // Instantiate the second four-bit adder for BCD correction
    four_bit_adder adder2(         
                      .a(binary_sum),     
                      .b({1'b0, binary_cout, binary_cout, 1'b0}), 
                      .cin(1'b0),         
                      .sum(sum),          
                      .cout(carry)        
                     );

    // Logic to detect BCD correction condition
    assign z1 = binary_sum & {1'b0, 1'b0, 1'b0, 1'b1}; // Check if sum > 9
    assign z2 = !binary_cout; // Check if carry is not present

    // Final carry is set if sum >9
    assign carry = z1 & z2;

endmodule