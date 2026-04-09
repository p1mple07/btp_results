ST_RX: begin
  if (p_valid_i) begin
    if (BIT_ORDER == 0) begin
      // LSB-first => store LSB in shift_reg_d[0]
      if (EXTRA_BIT == 1)
        shift_reg_d = {parity_bit, p_data_i};  // 9 bits if PARITY!=0
      else
        shift_reg_d = p_data_i;                // 8 bits if PARITY=0
    end
    else begin
      // MSB-first => store MSB in shift_reg_d[SHIFT_W-1]
      // If parity is used, it goes in the LSB or SHIFT_W-1?
      // We'll put it in the LSB if EXTRA_BIT=1
      if (EXTRA_BIT == 1) begin
        shift_reg_d[8:4] = {p_data_i[4:0],parity_bit};
        shift_reg_d[3:0] = p_data_i[8:5];
      end else
        shift_reg_d = p_data_i;
    end
  end
