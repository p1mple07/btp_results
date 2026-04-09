module bcd_adder(                
    input  [3:0] a,             // 4-bit BCD input
    input  [3:0] b,             // 4-bit BCD input
    output [3:0] sum,           // The corrected 4-bit BCD result of the addition
    output       cout           // Carry-out to indicate overflow beyond BCD range
);

    // Intermediate binary sum and its carry
    wire [3:0] binary_sum;
    wire       binary_cout;
    
    // Correction constant: if binary sum is 10 or greater, correction is needed (add 6)
    wire [3:0] corr_const;
    wire [3:0] corr_sum;
    wire       corr_cout;
    
    // First four-bit adder: perform binary addition of the two BCD inputs
    four_bit_adder adder1(         
        .a(a),            
        .b(b),            
        .cin(1'b0),       
        .sum(binary_sum), 
        .cout(binary_cout) 
    );
    
    // Determine if correction is needed:
    // If binary_sum is greater than or equal to 4'd10 then correction is required.
    assign corr_const = (binary_sum >= 4'd10) ? 4'b0110 : 4'b0000;
    
    // Second four-bit adder: apply BCD correction by adding 6 if needed
    four_bit_adder adder2(         
        .a(binary_sum),     
        .b(corr_const),     
        .cin(1'b0),         
        .sum(corr_sum),      
        .cout(corr_cout)    
    );
    
    // Final outputs: if correction was applied, cout will be 1; otherwise, cout remains 0.
    assign sum  = corr_sum;
    assign cout = corr_cout;

endmodule


module four_bit_adder(        
    input  [3:0] a,           // 4-bit input a
    input  [3:0] b,           // 4-bit input b
    input        cin,         // Carry input
    output [3:0] sum,         // 4-bit sum output
    output       cout         // Carry output
);

    // Declare a 4-bit vector for carry signals between full adders
    wire [3:0] carry;
    genvar i;
    
    generate
        // Least significant bit addition
        full_adder fa0(
            .a(a[0]),
            .b(b[0]),
            .cin(cin),
            .sum(sum[0]),
            .cout(carry[0])
        );
        
        // Generate loop for bits 1 to 3
        for (i = 1; i < 4; i = i + 1) begin : bit_adders
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i-1]),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate
    
    // The final carry-out is from the most significant full adder
    assign cout = carry[3];

endmodule


module full_adder(       
    input  a,      // First addend input
    input  b,      // Second addend input
    input  cin,    // Carry input
    output sum,    // Sum output
    output cout    // Carry output
);
                  
    // Sum is calculated using XOR of inputs
    assign sum = a ^ b ^ cin;
    
    // Carry is generated if any two or all three inputs are high
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule