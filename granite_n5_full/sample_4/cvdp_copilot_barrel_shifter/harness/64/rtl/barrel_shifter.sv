module barrel_shifter(
    input [7:0] data_in,
    input [2:0] shift_bits,
    input [2:0] mode,
    input logic enable,
    input logic signed
);
    
always @* begin
    case (mode)
        0: begin
        default: begin 
            // Your implementation code here 
    end
endmodule