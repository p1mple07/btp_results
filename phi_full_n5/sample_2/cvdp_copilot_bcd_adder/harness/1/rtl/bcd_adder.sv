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

    // Determine BCD correction condition logic
    assign z1 = binary_sum[3];
    assign z2 = binary_sum[2];

    // Apply BCD correction if needed
    assign sum[3] = z1 ? 4'b0 : binary_sum[3];
    assign sum[2] = z2 ? 4'b0 : binary_sum[2];
    assign cout = binary_cout & (z1 | z2);

endmodule


// Module of four_bit_adder
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
        // Instantiate four full adders for the four-bit adder
        for (i=0; i<4; i=i+1) begin : four_bit_adder_loop
            full_adder fa_inst(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

endmodule


// Module of full_adder
module full_adder(       
                  input a,     	// First Addend input
                  input b,     	// Second Addend input
                  input cin,   	// Carry input
                  output sum,  	// Sum output
                  output cout  	// Carry output
                );
                  
    assign sum = a ^ b ^ cin;                      // Calculate sum using XOR
    assign cout = (a & b) | (b & cin) | (a & cin); // Calculate carry-out
endmodule
