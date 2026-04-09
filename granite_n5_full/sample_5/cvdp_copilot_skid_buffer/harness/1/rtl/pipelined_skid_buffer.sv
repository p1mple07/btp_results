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
       
    
    reg         mem;
    reg         data_present;

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            mem <= 0;
            data_present <= 0;
        end else begin
            if (data_present &&!ready_o) begin
                mem <= data_i;
            end
            if (!data_present && valid_i && ready_i) begin
                mem <= data_i;
                data_present <= 1;
            end
        end
    end

    assign valid_o = data_present;
    assign ready_o = data_present ||!valid_i;
    assign data_o = data_present? mem : 0;

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


    reg  mem;
    reg  data_present;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem <= 0;
            data_present <= 0;
        end else begin
            if (valid_in && ready_in) begin
                mem <= data_in;
                data_present <= 1;
            end else begin
                data_present <= 0;
            end
        end
    end

    assign valid_out = data_present;
    assign ready_out = data_present;
    assign data_out = data_present? mem : 0;

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

reg         buffer;
reg [3:0] data_reg;
reg         data_present;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        buffer <= 0;
        data_present <= 0;
    end else begin
        if (i_valid && i_ready) begin
            buffer <= 1;
            data_present <= 1;
            data_reg <= i_data;
        end else begin
            buffer <= 0;
            data_present <= 0;
            data_reg <= {32{1'b0}};
        end

        if (data_present) begin
            o_data <= data_reg;
        end else begin
            o_data <= 0;
        end
    end

endmodule