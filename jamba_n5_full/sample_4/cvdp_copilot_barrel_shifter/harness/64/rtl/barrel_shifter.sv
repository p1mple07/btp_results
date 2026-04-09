module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,             
    input left_right,              
    input [data_width-1:0] mask,   
    input enable,                  
    input enable_parity,           
    output reg [data_width-1:0] data_out,
    output reg parity_out,        
    output reg error               
);

...
