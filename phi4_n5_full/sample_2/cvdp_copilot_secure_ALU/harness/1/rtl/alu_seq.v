module alu_seq (
    input i_clk,          
    input i_rst_b,        
    input [3:0] i_operand_a, 
    input [3:0] i_operand_b, 
    input [2:0] i_opcode,    
    input [7:0] i_key_in,    
    output reg [7:0] o_result 
);

  // Internal configurable security key (default: 0xAA)
  parameter p_key = 8'hAA;

  always @(posedge i_clk or negedge i_rst_b) begin
    if (!i_rst_b) begin
      o_result <= 8'b0;
    end else begin
      // Only perform operations if the provided key matches the internal key
      if (i_key_in == p_key) begin
        case (i_opcode)
          3'b000: o_result <= {4'b0, i_operand_a + i_operand_b};  // Addition
          3'b001: o_result <= {4'b0, i_operand_a - i_operand_b};  // Subtraction
          3'b010: o_result <= {4'b0, i_operand_a * i_operand_b};  // Multiplication
          3'b011: o_result <= {4'b0, i_operand_a & i_operand_b};  // Bitwise AND
          3'b100: o_result <= {4'b0, i_operand_a | i_operand_b};  // Bitwise OR
          3'b101: o_result <= {4'b0, ~i_operand_a};                // Bitwise NOT
          3'b110: o_result <= {4'b0, i_operand_a ^ i_operand_b};   // Bitwise XOR
          3'b111: o_result <= {4'b0, ~(i_operand_a ^ i_operand_b)}; // Bitwise XNOR
          default: o_result <= 8'b0;
        endcase
      end else begin
        o_result <= 8'b0;
      end
    end
  end

endmodule