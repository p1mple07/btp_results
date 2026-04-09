
always @(*) begin
  // default assignments: next_state = current_state, etc.
  next_state = current_state;
  next_load_cnt = load_cnt;
  next_find_cnt = find_cnt;
  next_count_cnt = count_cnt;
  next_prefix_cnt = prefix_cnt;
  next_build_cnt = build_cnt;
  next_copy_cnt = copy_cnt;
  next_done = done;
  next_out_data = out_data;
  // and for arrays, next_data_array[i] = data_array[i] for all i, next_out_array[i] = out_array[i] for all i, next_count_array[j] = count_array[j] for all j.
  // Then based on state, update transitions.
end
