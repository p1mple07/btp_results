
genvar i;
generate
  for(i = 0; i < NUM_INPUTS; i = i+1) begin : gen_tready
    assign s_axis_tready[i] = (i == sel) ? m_axis_tready : 1'b1;
  end
endgenerate
