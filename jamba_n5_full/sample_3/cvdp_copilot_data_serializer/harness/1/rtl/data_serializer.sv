if (EXTRA_BIT == 1) begin
  shift_reg_d[8:4] = {p_data_i[4:0],parity_bit};
  shift_reg_d[3:0] = p_data_i[8:5];
end else
  shift_reg_d = p_data_i;
