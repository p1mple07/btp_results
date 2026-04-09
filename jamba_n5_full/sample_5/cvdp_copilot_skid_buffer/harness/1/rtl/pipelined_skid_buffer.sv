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

    // Skid buffer instance
    skid_buffer skb (
        .clock(clock),
        .rst(rst),
        .data_i(data_i),
        .valid_i(valid_i),
        .o_ready(ready_o)
    );

    // Register to store data
    reg [3:0] reg_data;

    // Connect skid_buffer output to register input
    assign reg_data = skb.o_data;

    // Registers for data storage
    always @(posedge clock or posedge rst) begin
        if (!rst) begin
            reg_data[3:0] <= 0;
        end else begin
            reg_data[3:0] <= data_o;
        end
    end

    // Outputs
    assign data_o = reg_data[3:0];
    assign valid_o = reg_data[3] == 1'b1;
    assign ready_o = ready_i;

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

    reg [3:0] mem;

    always @(posedge clk or posedge rst) begin
        if (!rst) begin
            mem <= 0;
        end else begin
            mem <= data_in;
        end
    end

    assign ready_out = ready_in;
    assign valid_out = (mem != 0);
    assign data_out = mem[3:0];
    assign ready_out = ready_in;

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

    reg [3:0] data_reg;
    reg buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_reg <= 0;
            buffer <= 1'b0;
        end else begin
            if (i_valid) begin
                data_reg <= i_data;
                buffer <= 1'b1;
            end else begin
                data_reg <= 0;
                buffer <= 1'b0;
            end
        end
    end

    assign o_ready = buffer;
    assign o_data = data_reg;
    assign o_valid = buffer;
    assign i_ready = i_ready;

endmodule
