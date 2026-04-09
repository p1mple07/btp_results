top_microcode_sequencer
    input clock,
    input c_n_in,
    input c_inc_in,
    input d_in,
    input instr_in,
    input oe,
    input r_en,
    input reg_en,
    input stack_data_in,
    input stack_ram_in,
    input stack_addr_in,
    output d_out,
    output c_n_out,
    output full,
    output empty,
    output stack_full,
    output stack_empty,
    output pc_out,
    output pc_inc_out,
    output pc_dec_out,
    output arith_cout,
    output d_out_arith,
    output oe_arith,
    output push,
    output pop,
    output result_reg_out;

// Instantiate submodules
module stack_management (
    clk = clock,
    d_in = d_in,
    d_out = d_out,
    stack_data_in = stack_data_in,
    stack_data_out = stack_data_out,
    stack_addr_in = stack_addr_in,
    stack_addr_out = stack_addr_out,
    stack_we = stack_we,
    stack_re = stack_re,
    stack_full = stack_full,
    stack_empty = stack_empty
);
stack_management.stack_pointer out_stack_pointer;

module program_counter (
    clk = clock,
    full_adder_data_in = full_adder_data_in,
    pc_in = pc_in,
    pc_out = pc_out,
    pc_c_out = pc_c_out,
    pc_mux_sel = pc_mux_sel,
    pc_incrementer_data_in = pc_incrementer_data_in,
    pc_incrementer_c_in = pc_incrementer_c_in,
    pc_inc_out = pc_inc_out,
    pc_dec_out = pc_dec_out,
    pc_c_out = pc_c_out
);
program_counter.program_counter out_pc;

module microcode_arithmetic (
    clk = clock,
    a_in = a_in,
    b_in = b_in,
    a_mux_sel = a_mux_sel,
    b_mux_sel = b_mux_sel,
    full_adder_data_out = full_adder_data_out,
    d_out_arith = d_out_arith,
    oe_arith = oe_arith,
    arith_cout = arith_cout,
    d_out = d_out,
    oe = oe,
    reg_en = reg_en
);
microcode_arithmetic.a_mux a_mux;
microcode_arithmetic.b_mux b_mux;
microcode_arithmetic.a_mux_mux a_mux_mux;
microcode_arithmetic.b_mux_mux b_mux_mux;
aux_reg_mux a_mux_mux;
aux_reg a_reg;
aux_reg_mux b_mux_mux;
aux_reg b_reg;

module instruction_decoder (
   clk = clock,
    instr_in = instr_in,
    d_out = d_out,
    oe = oe,
    c_n_out = c_n_out,
    c_inc_out = c_inc_out,
    cc = cc,
    a_mux_sel = a_mux_sel,
    b_mux_sel = b_mux_sel,
    push = push,
    pop = pop,
    rst = rst,
    src_sel = src_sel,
    stack_we = stack_we,
    stack_re = stack_re,
    out_ce = out_ce
);
instruction_decoder.cin cin;
instruction_decoder.c_out c_out;
instruction_decoder.c_n_out c_n_out;
instruction_decoder.c_inc_out c_inc_out;
instruction_decoder.c_n_in c_n_in;
instruction_decoder.c_in cin;
instruction_decoder.c_out c_out;
instruction_decoder.c_n_out c_n_out;
instruction_decoder.c_inc_out c_inc_out;
instruction_decoder.c_n_in c_n_in;
instruction_decoder.c_in cin;
instruction_decoder.c_out c_out;
instruction_decoder.c_n_out c_n_out;
instruction_decoder.c_inc_out c_inc_out;

module result_register (
   clk = clock,
    data_in = d_out,
    oe = oe,
    data_out = result_reg_out
);
result_register.reg reg;