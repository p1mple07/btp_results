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

    wire [3:0] data_reg;
    reg buffer;

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            buffer <= 0;
            data_reg <= 4'b0000;
        end else begin
            if (ready_i' && !valid_i) begin
                buffer <= 1;
                data_reg <= 4'b0000;
            end else if (buffer) begin
                buffer <= 0;
                data_reg <= data_i;
            end
        end
    end

    assign valid_o = buffer && valid_i;
    assign ready_o = !buffer || (buffer && ready_i);
    assign data_o = buffer ? data_reg : 4'b0000;

endmodule

module register(
    input clk,
    input rst,

    input [3:0] data_in,
    input valid_in,
    output reg ready_out,
    output reg valid_out,
    output reg [3:0] data_out,
    input ready_in    
    );

    reg [3:0] data_reg;
    reg valid_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_reg <= 4'b0000;
            valid_reg <= 0;
        end else begin
            if (valid_in && ready_in) begin
                valid_reg <= 1;
                data_reg <= data_in;
            end else if (valid_reg) begin
                valid_reg <= 0;
                data_reg <= data_reg;
            end
        end
    end

    assign valid_out = valid_reg;
    assign ready_out = !valid_reg || (valid_reg && ready_in);
    assign data_out = valid_reg ? data_reg : 4'b0000;

endmodule

module skid_buffer(

input  clk,
input  reset ,

input  [3:0]i_data,
input  i_valid,
output o_ready,

output [3:0]o_data,
output o_valid,
input  i_ready

);

    wire [3:0] data_reg;
    reg buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer <= 0;
            data_reg <= 4'b0000;
        end else begin
            if (i_ready && !i_valid) begin
                buffer <= 1;
                data_reg <= i_data;
            end else if (buffer) begin
                buffer <= 0;
                data_reg <= data_reg;
            end
        end
    end

    assign o_ready = !buffer || (buffer && i_ready);
    assign o_valid = buffer && i_valid;
    assign o_data = buffer ? data_reg : 4'b0000;

endmodule
