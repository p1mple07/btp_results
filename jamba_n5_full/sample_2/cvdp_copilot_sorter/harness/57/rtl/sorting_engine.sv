
if ((l_addr <= left_end) && (r_addr <= right_end)) begin
    if (left_val <= right_val) begin
        tmp_merge[merge_idx] <= left_val;
        left_idx <= left_idx + 1;
    end else begin
        tmp_merge[merge_idx] <= right_val;
        right_idx <= right_idx + 1;
    end
    merge_idx <= merge_idx + 1;
end
else if (l_addr <= left_end) begin
    tmp_merge[merge_idx] <= left_val;
    left_idx <= left_idx + 1;
    merge_idx <= merge_idx + 1;
end
else if (r_addr <= right_end) begin
    tmp_merge[merge_idx] <= right_val;
    right_idx <= right_idx + 1;
    merge_idx <= merge_idx + 1;
end
else begin
    // Both sub-arrays are exhausted => write back merged results
    for (k = 0; k < N; k = k + 1) begin
        if ( (k < merge_idx) && (k < (subarray_size << 1)) && ((base_idx + k) < N) )
        begin
            data_mem[base_idx + k] <= tmp_merge[k];
        end
    }
