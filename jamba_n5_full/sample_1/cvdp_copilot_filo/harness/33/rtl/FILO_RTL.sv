
if (push && pop && empty) begin
    data_out <= data_in;
    feedthrough_data <= data_in;
    feedthrough_valid <= 1;
  end else begin
    ...
  end
