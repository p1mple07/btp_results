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
       
    // BCD correction logic
    // Case 1: Sum ≤ 9
    always @ (binary_sum) begin
        if (binary_sum <= 4'b1001) begin
            sum = binary_sum;
            cout = 1'b0;
        end
    end
    
    // Case 2: Sum > 9
    always @ (binary_sum) begin
        if (binary_sum > 4'b1001) begin
            sum = binary_sum + 4'b0110; // Add 6 to the sum
            cout = 1'b1;
        end
    end

    // Instantiate the second four-bit adder for BCD correction
    four_bit_adder adder2(         
                      .a(binary_sum),     
                      .b({1'b0, binary_cout, binary_cout, 1'b0}), 
                      .cin(1'b0),         
                      .sum(sum),          
                      .cout(carry)        
                     );
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
        for (i = 0; i < 4; i = i + 1) begin : adder_gen
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
