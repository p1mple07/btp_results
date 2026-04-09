// Insert code here to implement the combinational logic for the FSM of the Counting sort algorithm.
always @(*) begin
    // Transition from S_IDLE to S_LOAD_INPUT
    if (current_state == S_IDLE && start && !rst) begin
        current_state <= S_LOAD_INPUT;
        load_cnt <= 0;
        for (i = 0; i < N; i = i + 1) begin
            data_array[i] <= in_data[i*WIDTH +: WIDTH];
        end
    end

    // Transition from S_LOAD_INPUT to S_FIND_MAX
    if (current_state == S_LOAD_INPUT && start && !rst) begin
        current_state <= S_FIND_MAX;
        find_cnt <= 0;
        max_val <= 0;
        for (i = 0; i < N; i = i + 1) begin
            val = data_array[i];
            if (val > max_val) begin
                max_val <= val;
            end
        end
    end

    // Transition from S_FIND_MAX to S_COUNT
    if (current_state == S_FIND_MAX && start && !rst) begin
        current_state <= S_COUNT;
        count_cnt <= 0;
        for (i = 0; i < (1<<WIDTH); i = i + 1) begin
            count_array[i] <= 0;
        end
        for (i = 0; i < N; i = i + 1) begin
            val = data_array[i];
            count_array[val] <= count_array[val] + 1;
        end
    end

    // Transition from S_COUNT to S_PREFIX_SUM
    if (current_state == S_COUNT && start && !rst) begin
        current_state <= S_PREFIX_SUM;
        prefix_cnt <= 0;
        for (i = 0; i < (1<<WIDTH); i = i + 1) begin
            prefix_cnt[i] <= count_array[i];
        end
    end

    // Transition from S_PREFIX_SUM to S_BUILD_OUTPUT
    if (current_state == S_PREFIX_SUM && start && !rst) begin
        current_state <= S_BUILD_OUTPUT;
        build_cnt <= 0;
    end

    // Transition from S_BUILD_OUTPUT to S_COPY_OUTPUT
    if (current_state == S_BUILD_OUTPUT && start && !rst) begin
        current_state <= S_COPY_OUTPUT;
        copy_cnt <= 0;
    end

    // Transition from S_COPY_OUTPUT to S_DONE
    if (current_state == S_COPY_OUTPUT && start && !rst) begin
        current_state <= S_DONE;
        next_done = 1'b1;
    end

    // Transition from S_IDLE to S_LOAD_INPUT
    if (current_state == S_IDLE && !start && !rst) begin
        current_state <= S_IDLE;
        done <= 1'b0;
        out_data <= {N*WIDTH{1'b0}};
    end

    // Transition from S_FIND_MAX to S_COUNT
    if (current_state == S_FIND_MAX && !start && !rst) begin
        current_state <= S_FIND_MAX;
        next_find_cnt <= 0;
        next_max_val <= max_val;
    end

    // Transition from S_COUNT to S_PREFIX_SUM
    if (current_state == S_COUNT && !start && !rst) begin
        current_state <= S_PREFIX_SUM;
        next_count_cnt <= count_cnt;
        next_prefix_cnt <= prefix_cnt;
    end

    // Transition from S_PREFIX_SUM to S_BUILD_OUTPUT
    if (current_state == S_PREFIX_SUM && !start && !rst) begin
        current_state <= S_BUILD_OUTPUT;
        next_build_cnt <= build_cnt;
    end

    // Transition from S_BUILD_OUTPUT to S_COPY_OUTPUT
    if (current_state == S_BUILD_OUTPUT && !start && !rst) begin
        current_state <= S_COPY_OUTPUT;
        next_copy_cnt <= copy_cnt;
    end

    // Transition from S_COPY_OUTPUT to S_DONE
    if (current_state == S_COPY_OUTPUT && !start && !rst) begin
        current_state <= S_DONE;
        next_done <= 1'b1;
    end
end

// Transition from S_DONE to S_IDLE
always @(posedge clk) begin
    if (current_state == S_DONE) begin
        current_state <= S_IDLE;
        next_state <= S_IDLE;
    end
end

// Update next_state combinational logic
always @(current_state, in_data, start, done) begin
    case({current_state, in_data, start, done})
        S_IDLE: next_state = S_IDLE;
        S_LOAD_INPUT: next_state = S_FIND_MAX;
        S_FIND_MAX: next_state = S_COUNT;
        S_COUNT: next_state = S_PREFIX_SUM;
        S_PREFIX_SUM: next_state = S_BUILD_OUTPUT;
        S_BUILD_OUTPUT: next_state = S_COPY_OUTPUT;
        S_COPY_OUTPUT: next_state = S_DONE;
        S_DONE: next_state = S_IDLE;
    endcase
end

// Update next_count_array and next_out_array
always @(current_state) begin
    case(current_state)
        S_COUNT: begin
            next_count_array = count_array;
        end
        S_PREFIX_SUM: begin
            next_prefix_cnt = prefix_cnt;
            for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                next_count_array[i] = next_prefix_cnt[i];
            end
        end
        S_BUILD_OUTPUT: begin
            next_build_cnt = build_cnt;
            for (i = 0; i < N; i = i + 1) begin
                next_out_array[i] = out_array[i];
                for (j = 0; j < next_build_cnt; j = j + 1) begin
                    pos = next_count_array[i];
                    if (pos > 0) begin
                        next_out_array[i][pos-1] <= next_data_array[i][WIDTH-1];
                        pos = pos - 1;
                    end
                end
            end
        end
        S_COPY_OUTPUT: begin
            next_out_data = next_out_array;
        end
    endcase
end

// Update next_data_array
always @(current_state) begin
    case(current_state)
        S_LOAD_INPUT: begin
            next_data_array = data_array;
        end
        S_COUNT: begin
            next_data_array = {WIDTH{1'b0}};
        end
        S_BUILD_OUTPUT: begin
            next_data_array = next_out_array;
        end
    endcase
end

// Update next_max_val
always @(current_state) begin
    case(current_state)
        S_FIND_MAX: begin
            next_max_val = max_val;
        end
    end
end

// Update next_load_cnt, next_find_cnt, next_count_cnt, next_prefix_cnt, next_build_cnt, next_copy_cnt
always @(current_state) begin
    case(current_state)
        S_COUNT: begin
            next_load_cnt <= 0;
            next_find_cnt <= 0;
            count_cnt <= 0;
        end
        S_PREFIX_SUM: begin
            next_find_cnt <= 0;
            count_cnt <= prefix_cnt;
        end
        S_BUILD_OUTPUT: begin
            next_build_cnt <= 0;
        end
        S_COPY_OUTPUT: begin
            next_copy_cnt <= 0;
        end
    end
end
