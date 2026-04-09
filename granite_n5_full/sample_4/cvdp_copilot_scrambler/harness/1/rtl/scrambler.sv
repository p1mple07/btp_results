module scrambler(
    input logic [31:0] data_in,
    output logic [31:0] data_out
);
    reg [31:0] data_in;
    reg [31:0] data_out;
    
    always @(posedge clk) begin
        data_out <= data_in;
    end
endmodule