module microcode_sequencer(
    input clk,
    input c_n_in,
    input c_inc_in,
    input r_en,
    input cc,
    input ien,
    input [3:0] d_in,
    input [4:0] instr_in,
    output reg [3:0] d_out,
    output reg c_n_out,
    output reg c_inc_out,
    output reg full,
    output reg empty
);

    wire [4:0] stack_data_mux_out;
    wire [3:0] stack_data_out;
    wire [3:0] program_counter_out;

    // Instruction Decoder
    logic cen, rst, inc, pc_mux_sel, a_mux_sel, b_mux_sel, push, pop, src_sel;

    instruction_decoder #(.cc_in(cc), .ien(ien), .instr_in(instr_in))
        (
            .cen(cen),
            .rst(rst),
            .inc(inc),
            .pc_mux_sel(pc_mux_sel),
            .a_mux_sel(a_mux_sel),
            .b_mux_sel(b_mux_sel),
            .push(push),
            .pop(pop),
            .src_sel(src_sel),
            .stack_we(stack_we),
            .stack_re(stack_re),
            .out_ce(oen)
        );

    // Stack Management
    lifo_stack #(.stack_data_mux_out(stack_data_mux_out), .stack_data_out(stack_data_out), .full(full), .empty(empty))
        (
            .clk(clk),
            .stack_data1_in(d_in),
            .stack_data2_in(program_counter_out),
            .stack_reset(rst),
            .stack_push(push),
            .stack_pop(pop)
        );

    // Program Counter Control
    program_counter #(.pc_mux_sel(pc_mux_sel), .pc_inc_out(c_inc_out))
        (
            .clk(clk),
            .full_adder_data_i(stack_data_mux_out),
            .pc_c_in(c_inc_in),
            .inc(inc)
        );

    // Arithmetic Operations
    microcode_arithmetic #(.d_in(d_in), .stack_data_in(stack_data_out), .pc_data_in(program_counter_out), .reg_en(r_en), .oen(oen), .rce(rst), .a_mux_sel(a_mux_sel), .b_mux_sel(b_mux_sel), .arith_cin(cc), .cen(cen), .rce(rst))
        (
            .clk(clk),
            .fa_in(d_out),
            .a_in(stack_data_mux_out),
            .b_in(program_counter_out)
        );

    // Data Flow
    assign d_out = result_register #(.clk(clk), .data_in(d_out), .out_ce(oen))
        (
            .data_in(d_in)
        );

endmodule
