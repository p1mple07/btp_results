module bcd_adder(                
                 input  [3:0] a,             // 4-bit BCD input
                 input  [3:0] b,             // 4-bit BCD input
                 output [3:0] sum,           // The corrected 4-bit BCD result of the addition
                 output       cout           // Carry-out to indicate overflow beyond BCD range (i.e., when the result exceeds 9)
                );
    
    // Define wires for intermediate calculations
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
   
    // Detect BCD correction condition using case statement
    always @(*) begin
        case ({a[3], a[2], b[3], b[2]})
            4'b0000: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b0001: begin
                z1 = 1'b0;
                z2 = 1'b1;
            end
            4'b0010: begin
                z1 = 1'b0;
                z2 = 1'b1;
            end
            4'b0011: begin
                z1 = 1'b1;
                z2 = 1'b0;
            end
            4'b0100: begin
                z1 = 1'b1;
                z2 = 1'b0;
            end
            4'b0101: begin
                z1 = 1'b1;
                z2 = 1'b1;
            end
            4'b0110: begin
                z1 = 1'b1;
                z2 = 1'b1;
            end
            4'b0111: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b1000: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b10001: begin
                z1 = 1'b0;
                z2 = 1'b1;
            end
            4'b10010: begin
                z1 = 1'b0;
                z2 = 1'b1;
            end
            4'b10011: begin
                z1 = 1'b1;
                z2 = 1'b0;
            end
            4'b10100: begin
                z1 = 1'b1;
                z2 = 1'b0;
            end
            4'b10101: begin
                z1 = 1'b1;
                z2 = 1'b1;
            end
            4'b10110: begin
                z1 = 1'b1;
                z2 = 1'b1;
            end
            4'b10111: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b11000: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b110001: begin
                z1 = 1'b0;
                z2 = 1'b1;
            end
            4'b110010: begin
                z1 = 1'b0;
                z2 = 1'b1;
            end
            4'b110011: begin
                z1 = 1'b1;
                z2 = 1'b0;
            end
            4'b110100: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b110101: begin
                z1 = 1'b0;
                z2 = 1'b1;
            end
            4'b110110: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b110111: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b11100: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b11101: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b11110: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b111: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b1111: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b11110: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
            4'b11111: begin
                z1 = 1'b0;
                z2 = 1'b0;
            end
    endgenerate
endmodule