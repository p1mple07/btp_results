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
logic data_present;
logic buffer;

always_ff @(posedge clock) begin
    if (rst) begin
        data_present <= 0;
        buffer <= 0;
        data_reg <= 4'b0;
    end else begin
        if (valid_i &&!ready_i) begin
            data_present <= 1;
            buffer <= 1;
            data_reg <= data_i;
        end

        if (!valid_i && ready_i && buffer == 1) begin
            data_present <= 0;
            buffer <= 0;
        end
    end
end

assign valid_o = data_present && ready_i;
assign ready_o = data_present ||!valid_i;
assign data_o = data_present? data_reg : 4'b0;

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

always_ff @(posedge clk) begin
    if (rst) begin
        data_out <= 4'b0;
        valid_out <= 1'b0;
        ready_out <= 1'b0;
    end else begin
        if (valid_in &&!ready_in) begin
            data_out <= data_in;
            valid_out <= 1'b1;
            ready_out <= 1'b0;
        end

        if (!valid_in && ready_in) begin
            data_out <= 4'b0;
            valid_out <= 1'b0;
            ready_out <= 1'b1;
        end
    end
end

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

localparam SIZE = 4;

logic [SIZE-1:0] data_reg;
logic [SIZE-1:0] next_data_reg;
logic [SIZE-1:0] next_data_reg;
logic [SIZE-1:0] data_reg;
logic [SIZE-1:0] next_data_reg;

always_ff @(posedge clk) begin
    if (rst) begin
        data_reg <= {SIZE{1'b0}};
        next_data_reg <= {SIZE{1'b0}};
    end else begin
        data_reg <= {SIZE{1'b1}};
        next_data_reg <= {SIZE{1'b0}};
    end
endmodule