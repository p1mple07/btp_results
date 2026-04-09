module microcode_sequencer(
    input clk,
    input c_n_in,
    input c_inc_in,
    input r_en,
    input cc,
    input ien,
    input d_in[3:0],
    input instr_in[4:0],
    output reg d_out[3:0],
    output reg c_n_out,
    output reg c_inc_out,
    output reg full,
    output reg empty
);

    wire stack_push, stack_pop, stack_we, stack_mux_sel;
    wire pc_mux_sel;
    wire a_mux_sel[1:0], b_mux_sel[1:0];

    wire [4:0] stack_data_out, aux_reg_out, a_mux_out, b_mux_out, full_adder_out;

    // Instruction Decoder
    logic cen, rst, inc, pc_mux_sel, a_mux_sel, b_mux_sel;

    instruction_decoder #(.cc_in(cc), .ien(ien), .oen(r_en)) .
    (
        cen, rst, inc, pc_mux_sel, a_mux_sel, b_mux_sel,
        stack_push, stack_pop, stack_we, stack_mux_sel
    );

    // Stack Management
    lifo_stack #(.stack_data_mux_sel(stack_mux_sel), .stack_we(stack_we), .stack_re(full | empty)) .
    (
        stack_data_out, full, empty
    );

    // Program Counter
    program_counter #(.pc_mux_sel(pc_mux_sel), .inc(inc)) .
    (
        pc_out, pc_c_out
    );

    // Arithmetic Operations
    microcode_arithmetic #(.a_mux_sel(a_mux_sel), .b_mux_sel(b_mux_sel), .aux_reg_out(aux_reg_out), .arith_cout(full_adder_out)) .
    (
        d_out, arith_cout
    );

    // Logic
    assign d_out = (ien) ? aux_reg_out : 4'b0000;
    assign c_n_out = c_n_in;
    assign c_inc_out = c_inc_in;
    assign full = full_adder_out | (ien & stack_push);
    assign empty = !empty & stack_pop;

endmodule
