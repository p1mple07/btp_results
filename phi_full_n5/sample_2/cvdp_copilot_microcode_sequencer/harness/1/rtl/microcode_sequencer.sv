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

    wire full_o, empty_o;

    // Stack Management Submodule
    logic [4:0] stack_data_out;
    logic stack_addr, full, empty;
    wire stack_data1_in, stack_data2_in;
    wire stack_reset, stack_push, stack_pop, stack_mux_sel, stack_we, stack_re;

    lifo_stack lifo_stack_inst(
        .clk(clk),
        .stack_data1_in(d_in),
        .stack_data2_in(pc_out),
        .stack_reset(stack_reset),
        .stack_push(stack_push),
        .stack_pop(stack_pop),
        .stack_mux_sel(stack_mux_sel),
        .stack_we(stack_we),
        .stack_re(stack_re),
        .stack_data_out(stack_data_out),
        .full(full_o),
        .empty(empty_o)
    );

    // Program Counter Submodule
    logic pc_out, pc_c_out;
    wire pc_mux_sel;

    program_counter program_counter_inst(
        .clk(clk),
        .pc_data_in(pc_out),
        .pc_c_in(pc_c_in),
        .inc(inc),
        .pc_mux_sel(pc_mux_sel),
        .pc_out(pc_out),
        .pc_c_out(pc_c_out)
    );

    // Arithmetic Operations Submodule
    logic a_mux_sel[1:0], b_mux_sel[1:0];
    logic aux_reg_in, reg_out;
    logic aux_reg_mux_out;
    logic fa_in, a_mux_out, b_mux_out;
    logic full_adder_cout;
    logic arith_cout, d_out;

    microcode_arithmetic microcode_arithmetic_inst(
        .clk(clk),
        .fa_in(fa_in),
        .d_in(d_in),
        .stack_data_in(stack_data_out),
        .pc_data_in(pc_out),
        .a_mux_sel(a_mux_sel),
        .b_mux_sel(b_mux_sel),
        .aux_reg_in(aux_reg_in),
        .reg_out(reg_out),
        .oen(oen),
        .rce(rce),
        .cen(cen),
        .a_mux_out(a_mux_out),
        .b_mux_out(b_mux_out),
        .arith_cout(full_adder_cout),
        .d_out(d_out)
    );

    // Instruction Decoder Submodule
    logic cen, rst, push, pop, src_sel, stack_we, stack_re, pc_mux_sel, a_mux_sel, b_mux_sel, out_ce;

    instruction_decoder instruction_decoder_inst(
        .clk(clk),
        .instr_in(instr_in),
        .cc_in(cc),
        .cen(cen),
        .instr_en(ien),
        .rst(rst),
        .push(push),
        .pop(pop),
        .src_sel(src_sel),
        .stack_we(stack_we),
        .stack_re(stack_re),
        .pc_mux_sel(pc_mux_sel),
        .a_mux_sel(a_mux_sel),
        .b_mux_sel(b_mux_sel),
        .out_ce(out_ce)
    );

    // Result Register Submodule
    logic result_register_out;

    result_register result_register_inst(
        .clk(clk),
        .data_in(d_out),
        .out_ce(out_ce),
        .data_out(result_register_out)
    );

    // Combinational logic to generate control signals
    assign c_n_out = c_n_in;
    assign c_inc_out = c_inc_in;
    assign full = full_o;
    assign empty = empty_o;

    // Instruction decoding logic
    always @(posedge clk) begin
        case(instruction_decoder_inst.instr_in)
            5'b00000: begin
                d_out = 4'b0000;
                pc_c_in = 'b0;
                rst = 1'b1;
                stack_push = 1'b1;
            end
            5'b00001: begin
                d_out = pc_out;
            end
            5'b00010: begin
                d_out = aux_reg_out;
            end
            5'b00011: begin
                d_out = d_in;
            end
            5'b00100: begin
                d_out = {d_in[3], d_in[2], d_in[1], d_in[0]} + {pc_out[3], pc_out[2], pc_out[1], pc_out[0]};
                pc_c_in = inc;
            end
            5'b01011: begin
                stack_push = 1'b1;
                pc_out = pc_out;
            end
            5'b01110: begin
                pc_out = stack_data_out;
            end
            default: begin
                d_out = 4'bX;
            end
        end
    end
endmodule
