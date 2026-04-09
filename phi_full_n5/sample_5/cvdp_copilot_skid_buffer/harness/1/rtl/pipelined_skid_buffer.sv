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

    reg [3:0] buffer_reg;
    reg buffer_valid;
    reg buffer_ready;

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            buffer_reg <= 4'b0;
            buffer_valid <= 0;
            buffer_ready <= 0;
        end else begin
            if (ready_i) begin
                buffer_ready <= 1;
                buffer_valid <= valid_i;
                buffer_reg <= data_i;
            end else begin
                buffer_ready <= 0;
                buffer_valid <= 0;
            end
        end
    end

    assign data_o = buffer_reg;
    assign valid_o = buffer_valid;
    assign ready_o = buffer_ready;

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

    reg [3:0] data_reg;
    reg valid_reg;
    reg ready_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_reg <= 4'b0;
            valid_reg <= 0;
            ready_reg <= 0;
        end else begin
            if (valid_in && ready_in) begin
                data_reg <= data_in;
                valid_reg <= 1;
                ready_reg <= 1;
            end else begin
                data_reg <= data_reg;
                valid_reg <= valid_reg;
                ready_reg <= ready_reg;
            end
        end
    end

    assign data_out = data_reg;
    assign valid_out = valid_reg;
    assign ready_out = ready_reg;

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

    reg [3:0] buffer_reg;
    reg buffer_valid;
    reg buffer_ready;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_reg <= 4'b0;
            buffer_valid <= 0;
            buffer_ready <= 0;
        end else begin
            if (i_ready) begin
                buffer_ready <= 1;
                buffer_valid <= i_valid;
                buffer_reg <= i_data;
            end else begin
                buffer_ready <= 0;
                buffer_valid <= 0;
            end
        end
    end

    assign o_ready = buffer_ready;
    assign o_data = buffer_reg;
    assign o_valid = buffer_valid;

endmodule
