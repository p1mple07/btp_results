module multi_digit_bcd_add_sub #(parameter N = 4)(
    input  [4*N-1:0] A,           // N-digit BCD number
    input  [4*N-1:0] B,           // N-digit BCD number
    input            add_sub,     // 1 for addition, 0 for subtraction
    output [4*N-1:0] result,      // Result (sum or difference)
    output           carry_borrow // Carry-out for addition or Borrow-out for subtraction
);
    wire [N:0] carry;          // Carry between digits
    wire [4*N-1:0] B_comp;     // Complemented B for subtraction
    wire [4*N-1:0] operand_B;  // Operand B after considering addition or subtraction

    assign carry[0] = add_sub ? 1'b0 : 1'b1; 

    // Generate 9's complement of B for subtraction
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin 
            assign B_comp[4*i+3:4*i] = 4'b1001 - B[4*i+3:4*i]; 
        end
    endgenerate

    assign operand_B = add_sub ? B : B_comp;

    generate
        for (i = 0; i < N; i = i + 1) begin 
            bcd_adder bcd_adder_inst(
                .a(A[4*i+3:4*i]),
                .b(operand_B[4*i+3:4*i]),
                .cin(carry[i]),
                .sum(result[4*i+3:4*i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign carry_borrow = carry[N]; 
endmodule

//module of bcd_adder
module bcd_adder(                
                 input  [3:0] a,             // 4-bit BCD input
                 input  [3:0] b,             // 4-bit BCD input
                 input        cin,           // Carry-in
                 output [3:0] sum,           // The corrected 4-bit BCD result of the addition
                 output       cout           // Carry-out to indicate overflow beyond BCD range (i.e., when the result exceeds 9)
                );
    
wire [3:0] binary_sum;         
wire binary_cout;              
wire z1, z2;                   
wire carry;                    
   
four_bit_adder adder1(         
                      .a(a),            
                      .b(b),            
                      .cin(cin),       
                      .sum(binary_sum), 
                      .cout(binary_cout) 
                     );
       
assign z1 = (binary_sum[3] & binary_sum[2]); 
assign z2 = (binary_sum[3] & binary_sum[1]); 
assign cout = (z1 | z2 | binary_cout);        

four_bit_adder adder2(         
                      .a(binary_sum),     
                      .b({1'b0, cout, cout, 1'b0}), 
                      .cin(1'b0),         
                      .sum(sum),          
                      .cout(carry)        
                     );

endmodule     


//module of four_bit_adder
module four_bit_adder(        
                      input [3:0] a,           // 4-bit input a
                      input [3:0] b,           // 4-bit input b
                      input cin,               // Carry input
                      output [3:0] sum,        // 4-bit sum output
                      output cout              // Carry output
                     );

  wire [2:0] carry;         

  genvar i;                 

  generate
    for (i = 0; i < 4; i = i + 1) begin: adder 

      if (i == 0) begin
        full_adder fa (       
                       .a(a[i]),           
                       .b(b[i]),           
                       .cin(cin),          
                       .sum(sum[i]),       
                       .cout(carry[i])     
                      );
      end 
      else if (i < 3) begin
        full_adder fa (       
                       .a(a[i]),           
                       .b(b[i]),           
                       .cin(carry[i-1]),   
                       .sum(sum[i]),       
                       .cout(carry[i])     
                      );
      end
      else begin
        full_adder fa (       
                       .a(a[i]),           
                       .b(b[i]),           
                       .cin(carry[i-1]),   
                       .sum(sum[i]),       
                       .cout(cout)         
                     );
      end
    end
  endgenerate

endmodule     

//module of full_adder
module full_adder(       
                  input a,     // First Addend input
                  input b,     // Second Addend input
                  input cin,   // Carry input
                  output sum,  // Sum output
                  output cout  // Carry output
                );
                  
  assign sum = a ^ b ^ cin;                      
  assign cout = (a & b) | (b & cin) | (a & cin); 
  
endmodule