// Combinational logic for the FSM of the Counting sort algorithm
always @(*) begin
    // Initialize next state and values
    next_state = current_state;
    next_max_val = max_val;
    next_load_cnt = load_cnt;
    next_find_cnt = find_cnt;
    next_count_cnt = count_cnt;
    next_prefix_cnt = prefix_cnt;
    next_build_cnt = build_cnt;
    next_copy_cnt = copy_cnt;
    next_done = done;
    next_out_data = out_data;

    // Find maximum value
    if (current_state == S_LOAD_INPUT) begin
        max_val = 0;
        for (i = 0; i < N; i = i + 1) begin
            val = data_array[i];
            if (val > max_val) begin
                max_val = val;
            end
        end
    end

    // Count occurrences
    if (current_state == S_FIND_MAX) begin
        find_cnt = N;
        for (i = 0; i < N; i = i + 1) begin
            count_array[val] = count_array[val] + 1;
        end
    end

    // Compute prefix sum
    if (current_state == S_COUNT) begin
        prefix_cnt = 0;
        for (i = 0; i < (1 << WIDTH); i = i + 1) begin
            prefix_cnt = prefix_cnt + count_array[i];
        end
    end

    // Build output array
    if (current_state == S_BUILD_OUTPUT) begin
        build_cnt = N;
        for (i = N-1; i >= 0; i = i - 1) begin
            for (j = 0; j < (1 << WIDTH); j = j + 1) begin
                if (count_array[j] > 0 && prefix_cnt >= j) begin
                    out_array[i] = j;
                    next_out_data[i] = j;
                    count_array[j] = count_array[j] - 1;
                    prefix_cnt = prefix_cnt - 1;
                    break;
                end
            end
        end
    end

    // Copy output to done signal
    if (current_state == S_COPY_OUTPUT) begin
        copy_cnt = N;
        for (i = 0; i < N; i = i + 1) begin
            out_data[i] = next_out_data[i];
            next_done = 1'b1;
        end
    end

    // Update current state
    case (current_state)
        S_IDLE: next_state = S_LOAD_INPUT;
        S_LOAD_INPUT: next_state = S_FIND_MAX;
        S_FIND_MAX: next_state = S_COUNT;
        S_COUNT: next_state = S_PREFIX_SUM;
        S_PREFIX_SUM: next_state = S_BUILD_OUTPUT;
        S_BUILD_OUTPUT: next_state = S_COPY_OUTPUT;
        S_COPY_OUTPUT: next_state = S_DONE;
        S_DONE: next_state = S_IDLE;
    endcase
end
