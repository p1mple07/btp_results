
if ((l_addr <= left_end) && (r_addr <= right_end))
    if (left_val <= right_val)
        tmp_merge[merge_idx] <= left_val;
        left_idx <= left_idx + 1;
    else
        tmp_merge[merge_idx] <= right_val;
        right_idx <= right_idx + 1;
    merge_idx <= merge_idx + 1;
else if (l_addr <= left_end)
    ... etc.
