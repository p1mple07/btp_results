microcode_sequencer
  input clock,
  input c_n_in,
  input c_inc_in,
  input reg_en,
  input r_en,
  input d_in,
  output d_out,
  output oe,
  output c_n_out,
  output c_inc_out,
  output full,
  output empty;

reg [4:0] address;

reg [4:0] result;

reg [4:0] stack_data;

reg [4:0] program_counter;

reg [4:0] result_register;

always @(posedge clock) begin
  case (instr_in)
    5'b00000: address = 4'b0000;
    5'b00001: address = program_counter;
    5'b00010: address = result;
    5'b00011: address = stack_data;
    5'b00100: address = program_counter;
    5'b00111: address = (program_counter + d_in);
    default: address = 4'b0000;
  endcase

  result_register = address;
  d_out = result;
end