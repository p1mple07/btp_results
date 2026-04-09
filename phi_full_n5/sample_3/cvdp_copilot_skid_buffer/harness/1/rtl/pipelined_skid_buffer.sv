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

    // Register to maintain validity of data
    always @(posedge clock or posedge rst) begin
        if (rst) begin
            buffer_reg <= 4'b0;
            buffer_valid <= 0;
            buffer_ready <= 0;
        end else begin
            if (valid_i && !buffer_ready) begin
                buffer_reg <= data_i;
                buffer_valid <= 1;
                buffer_ready <= ready_i;
            end
            data_o <= buffer_reg;
            valid_o <= buffer_valid;
            ready_o <= buffer_ready;
        end
    end
endmodule

module register(
    input clk,
    input rst,

    input [3:0] data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0] data_out,
    input ready_in    
    );

    reg [3:0] mem_reg;
    reg valid_out;
    reg ready_out;

    // Register to store data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_reg <= 4'b0;
            valid_out <= 0;
            ready_out <= 0;
        end else begin
            if (valid_in && !ready_in) begin
                mem_reg <= data_in;
                valid_out <= 1;
                ready_out <= ready_in;
            end
            data_out <= mem_reg;
            valid_out <= valid_out;
            ready_out <= ready_out;
        end
    end
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

    // Skid buffer logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_reg <= 4'b0;
            buffer_valid <= 0;
            buffer_ready <= 0;
        end else begin
            if (i_valid && !i_ready) begin
                buffer_reg <= i_data;
                buffer_valid <= 1;
                buffer_ready <= 0;
            end
            o_ready <= buffer_ready;
            o_data <= buffer_reg;
            o_valid <= buffer_valid;
        end
    end
endmodule
