module microcode_sequencer #(
    parameter OPERATING_FREQUENCY = 50'hMHz
) (
    input wire clk,
    input wire c_inc_in,
    input wire c_inc_in, // Wait: the spec says "c_inc_in(1-bit)"? Actually the spec shows "c_inc_in" under "Inputs" for microcode_sequencer. In the interface, it's "c_inc_in(1-bit): Carry-in for the program counter incrementer." So we should have a single input c_inc_in. But the parameter above says "c_inc_in" as a 1-bit. So we can use c_inc_in.
    input wire c_inc_in,
    input wire r_en,
    input wire cc,
    input wire en,
    input wire instr_in,
    input wire oen,
    input wire instr_en,
    input wire d_in,
    input wire out_ce,
    output reg d_out,
    output reg c_n_out,
    output reg c_inc_out,
    output reg full,
    output reg empty
);
