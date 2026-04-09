
assign load_data_gain = {load_data_int_out[DATA_WIDTH-1], load_data_int_out, 1'b0} + {{(2){load_data_int_out[DATA_WIDTH-1]}}, load_data_int_out};
