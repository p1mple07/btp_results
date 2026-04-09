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

logic [3:0] data_reg;
logic buffer;

always @(posedge clock) begin
    if (rst) begin
        data_reg <= 4'd0;
        buffer <= 1'b0;
    end else if (valid_i &&!buffer) begin
        data_reg <= data_i;
        buffer <= 1'b1;
    end else if (ready_i && buffer) begin
        data_o <= data_reg;
        valid_o <= 1'b1;
        buffer <= 1'b0;
    end else begin
        valid_o <= 1'b0;
    end
end

assign ready_o =!buffer;

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

logic [3:0] data_reg;
logic buffer;

always @(posedge clk) begin
    if (rst) begin
        data_reg <= 4'd0;
        buffer <= 1'b0;
    end else if (valid_in &&!buffer) begin
        data_reg <= data_in;
        buffer <= 1'b1;
    end else if (ready_in && buffer) begin
        data_out <= data_reg;
        valid_out <= 1'b1;
        buffer <= 1'b0;
    end else begin
        valid_out <= 1'b0;
    end
end

assign ready_out =!buffer;

endmodule


module skid_buffer(

input  clk,
input  reset,

input  [3:0]i_data,
input  i_valid,
output o_ready,

output [3:0]o_data,
output o_valid,
input  i_ready

);

logic [3:0] data_reg;
logic buffer;

always @(posedge clk) begin
    if (rst) begin
        data_reg <= 4'd0;
        buffer <= 1'b0;
    end else if (valid_i &&!buffer) begin
        data_reg <= data_i;
        buffer <= 1'b1;
    end else if (ready_i && buffer) begin
        data_o <= data_reg;
        valid_o <= 1'b1;
        buffer <= 1'b0;
    end else begin
        valid_o <= 1'b0;
    end
end

assign ready_o =!buffer;

endmodule