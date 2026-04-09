module scrambler (
    input  wire clk,
    input  wire rst_n,
    input  wire [15:0] data_in,
    input  wire [15:0] data_out,
    input  wire [2:0] mode
);
    
    reg [15:0] data_in;
    reg [15:0] data_out;
    reg [2:0] mode;
    
endmodule