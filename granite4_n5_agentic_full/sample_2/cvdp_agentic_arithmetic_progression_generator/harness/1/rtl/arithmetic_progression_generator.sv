assign out_val = (current_val >= (1 << WIDTH_OUT_VAL - 1))? ((1 << WIDTH_OUT_VAL - 1) - 1) : (current_val + step_size);

assign out_val = (counter == 0)? start_val : (current_val + step_size);