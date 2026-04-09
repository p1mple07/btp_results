`include "rtl/constants.svh"  // Assumes constants like WIDTH_4BIT are defined

module microcode_sequencer #(
    parameter WIDTH_4BIT = 4
)(
    input wire clk,
    input wire c_n_in,
    input wire c_inc_in,
    input wire r_en,
    input wire cc,
    input wire ien,
    input wire d_in,
    input wire instr_in,
    input wire oen,

    output reg d_out,
    output wire c_n_out,
    output wire c_inc_out,
    output reg full,
    output reg empty,

    output reg r_en_out,
    output reg oen_out,

    output reg push,
    output reg pop,
    output reg src_sel,
    output reg stack_we,
    output reg stack_re,

    output reg out_ce,
    output reg data_out
);

    // Stack Management (LIFO)
    stack_pointer #(.WIDTH(5))  stack_pointer_inst (
        .clk(clk),
        .rst(rst_init),
        .push(push),
        .pop(pop),
        .stack_addr(stack_addr),
        .stack_full(full),
        .stack_empty(empty)
    );

    stack_ram #(.WIDTH(WIDTH_4BIT))  stack_ram_inst (
        .clk(clk),
        .rst(rst_init),
        .clock_en(rst_init),
        .write_en(stack_we),
        .read_en(stack_re),
        .write_data(stack_data_out),
        .read_data(stack_data_in),
        .stack_addr(stack_addr),
        .stack_full(full),
        .stack_empty(empty)
    );

    stack_data_mux #(.WIDTH(WIDTH_4BIT))  stack_data_mux_inst (
        .data_in(stack_data_out),
        .data_out(stack_data_in),
        .stack_mux_sel(stack_mux_sel)
    );

    // Program Counter Control
    program_counter #(.WIDTH(WIDTH_4BIT))  pc_inst (
        .clk(clk),
        .rst(rst_init),
        .full_o(full_o),
        .empty_o(empty_o),
        .pc_data_in(pc_data_in),
        .pc_c_in(pc_c_in),
        .pc_mux_sel(pc_mux_sel),
        .pc_inc_out(pc_c_out),
        .pc_data_out(pc_data_out),
        .pc_reg_out(pc_reg_out)
    );

    pc_incrementer #(.WIDTH(WIDTH_4BIT))  pc_inc_inst (
        .clk(clk),
        .pc_c_in(pc_c_in),
        .inc(inc),
        .pc_data_in(pc_data_in),
        .pc_c_out(pc_c_out),
        .pc_data_out(pc_data_out),
        .pc_c_in(pc_c_in)
    );

    pc_reg #(.WIDTH(WIDTH_4BIT))  pc_reg_inst (
        .clk(clk),
        .pc_data_in(pc_data_in),
        .pc_reg_out(pc_reg_out)
    );

    // Arithmetic Operations
    microcode_arithmetic #(.WIDTH(WIDTH_4BIT))  microcode_arithmetic_inst (
        .clk(clk),
        .rst(rst_init),
        .a_in(a_mux_sel_data),
        .b_in(b_mux_sel_data),
        .c_in(arith_cin),
        .ae_en(ae_en),
        .oe(oe),
        .reg_en(reg_en),
        .d_out(d_out),
        .arith_cout(arith_cout),
        .d_in(d_in),
        .stack_data_in(stack_data_in),
        .pc_data_in(pc_data_in),
        .full_o(full_o),
        .empty_o(empty_o)
    );

    microcode_sequencer_control #(.WIDTH(WIDTH_4BIT))  microcode_seq_inst (
        .clk(clk),
        .rst(rst_init),
        .instr_in(instr_in),
        .cc(cc),
        .ien(ien),
        .r_en(r_en),
        .oen(oen),
        .ocn(ocn),
        .inc(inc),
        .rce(rce),
        .cen(cen),
        .a_mux_sel(a_mux_sel),
        .b_mux_sel(b_mux_sel),
        .push(push),
        .pop(pop),
        .src_sel(src_sel),
        .stack_we(stack_we),
        .stack_re(stack_re),
        .out_ce(out_ce),
        .data_out(data_out)
    );

    // Result Register
    result_register #(.WIDTH(WIDTH_4BIT))  result_reg_inst (
        .clk(clk),
        .rst(rst_init),
        .data_in(d_out),
        .out_ce(out_ce),
        .data_out(data_out)
    );

endmodule
