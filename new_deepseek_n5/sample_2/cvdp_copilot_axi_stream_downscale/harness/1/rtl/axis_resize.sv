module axis_resize (
  input clock,
  input resetn,
  input s_valid,
  input s_data,
  output s_ready,
  output m_valid,
  input m_ready,
  output m_data
);

  reg s_valid_reg = 1;
  reg m_valid_reg = 0;
  reg m_data_reg;

  if (resetn) 
    m_data = 8'b0;
    s_ready = 1;
  else 
    if (m_ready) 
      m_data = (s_data >> 8);
      m_valid = 1;
      s_ready = 1;
    else 
      m_valid = 0;
      s_ready = 0;
    end
  end

  // Negative edge-sensitive assignment
  m_data = m_data_reg;
  m_valid = m_valid_reg;

endmodule