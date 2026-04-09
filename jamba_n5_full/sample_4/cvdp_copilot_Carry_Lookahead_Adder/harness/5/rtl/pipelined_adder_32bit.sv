module pipelined_adder_32bit (
    input clk,       // Synchronous to posedge of clk 
    input reset,     // Synchronous active high reset
    input [31:0] A,  // 32 bit operand for addition  
    input [31:0] B,  // 32 bit operand for addition  
    input start,     // Active high signal to indicate when valid input data is provided
    output [31:0] S, // Final sum or result 
    output Co,       // Final carry out 
    output done      // Completion signal, active high when computation is complete    
);
