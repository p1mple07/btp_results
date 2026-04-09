// encoder_64b66b.sv
input clock_in;
input rst_in;
input [63:0] encoder_data_in;
input [7:0] encoder_control_in;
output [65:0] encoder_data_out;

reg [65:0] encoder_data_out;

always @posedge clock_in or posedge rst_in begin
    if (rst_in) 
        encoder_data_out = 64'h0000000000000000;
    else 
        if (encoder_control_in == 8'b00000000)
            encoder_data_out = {2'b01, encoder_data_in};
        else
            encoder_data_out = {2'b10, 64'h0000000000000000};
end