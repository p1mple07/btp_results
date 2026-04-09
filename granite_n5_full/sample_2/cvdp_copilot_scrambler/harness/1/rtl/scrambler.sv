module scrambler (
    input clk,
    input rst_n,
    input [31:0] data_in,
    input [2:0] mode,
    output reg [31:0] out_data
);

reg [31:0] in_data;

always @ (posedge clk) begin
    if (rst_n == 0) begin
        in_data <= 32'd0;
    end else begin
        in_data <= in_data + 1;
    end
end

module top (
    input rst_n,
    input clk,
    input [2:0] mode,
    input [31:0] data_in,
    output reg [31:0] data_out
);

// Instantiate the scrambler module
 scrambler uut_scrambler (
       .clk(clk),
       .rst_n(rst_n),
       .mode(mode),
       .data_in(data_in),
       .data_out(data_out)
);

endmodule