// Insert code here to compute parity_0 and parity_1

always @(*) begin
  feedback = {data_in[DATA_WIDTH-2:0], parity_0} ^ parity_1;
  parity_1 = {parity_0[DATA_WIDTH-2:0], data_in};
  parity_0 = feedback;
end