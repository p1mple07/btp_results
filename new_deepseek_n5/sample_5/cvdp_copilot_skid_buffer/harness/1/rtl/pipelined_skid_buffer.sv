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

    // Input skid buffer
    wire [3:0] data_skid0_out;
    wire [3:0] data_reg1_in;
    wire [3:0] data_skid2_out;
    wire [3:0] data_reg3_out;

    // Register 1
    register reg1(
        input  clock,
        input  rst,
        input [3:0] data_in = data_skid0_out,
        input valid_in = valid_i,
        output ready_out = ready_i,
        output valid_out = valid_i,
        output [3:0] data_out = data_reg1_in,
        input  ready_in
    );

    // Register 2
    register reg3(
        input  clock,
        input  rst,
        input [3:0] data_in = data_skid2_out,
        input valid_in = valid_i,
        output ready_out = ready_o,
        output valid_out = valid_o,
        output [3:0] data_out = [3:0] '0',
        input  ready_in
    );

    // Skid buffer 0
    skid_buffer skid0(
        input  clock,
        input  rst,
        input [3:0] data_in = data_i,
        input valid_in = valid_i,
        output o_ready = ready_i,
        output [3:0] o_data = data_skid0_out,
        output o_valid = valid_i,
        input  i_ready = ready_i
    );

    // Skid buffer 2
    skid_buffer skid2(
        input  clock,
        input  rst,
        input [3:0] data_in = data_reg1_out,
        input valid_in = valid_i,
        output o_ready = ready_i,
        output [3:0] o_data = data_skid2_out,
        output o_valid = valid_i,
        input  i_ready = ready_i
    );
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

    // Internal register
    reg mem;
    reg data_present;

    always @(clk) begin
        if (rst) begin
            mem = 0;
            data_present = 0;
        else if (valid_in) begin
            mem = data_in;
            data_present = 1;
        else begin
            mem = mem;
            data_present = 0;
        end
    end

    // Output
    data_out = mem;
    valid_out = data_present;
    ready_out = ready_in;
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

    // Internal register
    reg data_reg;
    reg buffer;

    always @(clk) begin
        if (reset) begin
            data_reg = 0;
            buffer = 0;
        else if (i_valid && !i_ready) begin
            buffer = 1;
            data_reg = i_data;
        else if (!i_valid || i_ready) begin
            buffer = 0;
        end
    end

    // Output
    o_data = data_reg;
    o_valid = buffer;
    o_ready = 0;
endmodule