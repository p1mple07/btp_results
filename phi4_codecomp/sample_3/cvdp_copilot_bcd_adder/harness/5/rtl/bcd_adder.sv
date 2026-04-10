module bcd_adder(                
                 input  [3:0] a,             // 4-bit BCD input
                 input  [3:0] b,             // 4-bit BCD input
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
                      .cin(1'b0),       
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