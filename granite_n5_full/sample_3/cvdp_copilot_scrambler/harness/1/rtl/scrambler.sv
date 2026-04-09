module scrambler (input clk, rst_n, input [31:0] data_in, output [31:0] data_out);
    reg [31:0] data_in;
    wire [31:0] data_out;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in <= 32'h00000000
        end
    end

endmodule