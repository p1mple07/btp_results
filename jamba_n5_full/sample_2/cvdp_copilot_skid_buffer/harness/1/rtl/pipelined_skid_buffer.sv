module pipelined_skid_buffer(
    input wire clock,
    input wire rst,

    input wire [3:0] data_i,
    input wire valid_i,
    output wire ready_o,
    output wire valid_o,
    output wire [3:0] data_o,
    input wire ready_i

    );    
//insert your code here

endmodule

module register(
    input clk,
    input rst,

    input [3:0] data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0] data_out,
    input  ready_in    
    );
//insert your code here

endmodule


module skid_buffer(

input  clk,
input  reset ,

input  [3:0]i_data,
input  i_valid,
output o_ready,,

output [3:0]o_data,,
output o_valid,,
input  i_ready

);

//insert your code here

endmodule
