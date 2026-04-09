
module sigma_delta_audio
(
  input   clk_sig,
  input   clk_en_sig,
  input  [14:0] load_data_sum,
  input  [14:0] read_data_sum,
  output  reg left_sig=0,
  output  reg right_sig=0
);

... some always blocks ...

wire [DATA_WIDTH+2-1:0] load_data_gain, read_data_gain;
assign load_data_gain = {load_data_int_out[DATA_WIDTH-1], load_data_int_out, 1'b0} + {{(2){load_data_int_out[DATA_WIDTH-1]}}, load_data_int_out};
assign read_data_gain = {read_data_int_out[DATA_WIDTH-1], read_data_int_out, 1'b0} + {{(2){read_data_int_out[DATA_WIDTH-1]}}, read_data_int_out};

assign l_aca1 = {{(A1_WIDTH){load_data_gain[DATA_WIDTH+2-1]}}, load_data_gain} - {{(A1_WIDTH){l_er0[DATA_WIDTH+2-1]}}, l_er0} + l_ac1;
assign r_aca1 = {{(A1_WIDTH){read_data_gain[DATA_WIDTH+2-1]}}, read_data_gain} - {{(A1_WIDTH){r_er0[DATA_WIDTH+2-1]}}, r_er0} + r_ac1;
assign l_aca2 = {{(A2_WIDTH-A1_WIDTH){l_aca1[DATA_WIDTH+A1_WIDTH+2-1]}}, l_aca1} - {{(A2_WIDTH){l_er0[DATA_WIDTH+2-1]}}, l_er0} - {{(A2_WIDTH+1){l_er0_prev[DATA_WIDTH+2-1]}}, l_er0_prev[DATA_WIDTH+2-1:1]} + l_ac2;
assign r_aca2 = {{(A2_WIDTH-A1_WIDTH){r_aca1[DATA_WIDTH+A1_WIDTH+2-1]}}, r_aca1} - {{(A2_WIDTH){r_er0[DATA_WIDTH+2-1]}}, r_er0} - {{(A2_WIDTH+1){r_er0_prev[DATA_WIDTH+2-1]}}, r_er0_prev[DATA_WIDTH+2-1:1]} + r_ac2;

always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    l_ac1 <= #1 l_aca1;
    r_ac1 <= #1 r_aca1;
    l_ac2 <= #1 l_aca2;
    r_ac2 <= #1 r_aca2;
  end
end

assign l_quant = {l_ac2[DATA_WIDTH+A2_WIDTH+2-1], l_ac2} + {{(DATA_WIDTH+A2_WIDTH+3-READ_WIDTH){s_out[READ_WIDTH-1]}}, s_out[READ_WIDTH-1:0]};
assign r_quant = {r_ac2[DATA_WIDTH+A2_WIDTH+2-1], r_ac2} + {{(DATA_WIDTH+A2_WIDTH+3-READ_WIDTH){s_out[READ_WIDTH-1]}}, s_out[READ_WIDTH-1:0]};

assign l_er0 = l_quant[DATA_WIDTH+A2_WIDTH+3-1] ? {1'b1, {(DATA_WIDTH+2-1){1'b0}}} : {1'b0, {(DATA_WIDTH+2-1){1'b1}}};
assign r_er0 = r_quant[DATA_WIDTH+A2_WIDTH+3-1] ? {1'b1, {(DATA_WIDTH+2-1){1'b0}}} : {1'b0, {(DATA_WIDTH+2-1){1'b1}}};

always @ (posedge clk_sig)
begin
  if (clk_en_sig)
  begin
    if (~|load_data_gain)
    begin
      left_sig <= #1 ~left_sig;
    end
    else
    begin
      left_sig <= #1 ~l_er0[DATA_WIDTH+2-1];
    end

    if (~|read_data_gain)
    begin
      right_sig <= #1 ~right_sig;
    end
    else
    begin
      right_sig <= #1 ~r_er0[DATA_WIDTH+2-1];
    end
  end
end
endmodule
