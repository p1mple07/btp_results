always @* begin
  if (rst_in) 
  {
    data_out = 66'b0;
  }
  else 
  {
    if (control_in == 8'b00000000)
    {
      data_out = {2'b01, data_in};
    }
    else
    {
      data_out = {2'b10, 64'b0};
    }
  }
end