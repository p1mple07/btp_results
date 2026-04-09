// Insert code here to implement the combinational logic for the FSM of the Counting sort algorithm.
always @(*) begin
    case (current_state)
        S_IDLE: begin
            if (start) begin
                current_state <= S_LOAD_INPUT;
            end else begin
                next_state <= S_IDLE;
            end
        end
        S_LOAD_INPUT: begin
            if (N > 0) begin
                load_cnt <= N;
                next_state <= S_FIND_MAX;
            end else begin
                next_state <= S_IDLE;
            end
        end
        S_FIND_MAX: begin
            max_val <= data_array[0];
            for (i = 1; i < N; i = i + 1) begin
                if (data_array[i] > max_val) begin
                    max_val <= data_array[i];
                end
            end
            next_state <= S_COUNT;
            next_max_val <= max_val;
        end
        S_COUNT: begin
            count_cnt <= 0;
            for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                count_array[i] <= 0;
            end
            for (i = 0; i < N; i = i + 1) begin
                val = data_array[i];
                pos = val / WIDTH;
                count_array[pos] <= count_array[pos] + 1;
            end
            next_state <= S_PREFIX_SUM;
            next_count_array <= count_array;
        end
        S_PREFIX_SUM: begin
            prefix_cnt <= 0;
            prefix_cnt <= count_array;
            for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                prefix_cnt[i] <= prefix_cnt[i] + count_array[i];
            end
            next_state <= S_BUILD_OUTPUT;
            next_prefix_cnt <= prefix_cnt;
        end
        S_BUILD_OUTPUT: begin
            build_cnt <= 0;
            for (i = N-1; i >= 0; i = i - 1) begin
                out_array[i] <= prefix_cnt[(val >> WIDTH) - 1];
                build_cnt <= build_cnt + 1;
            end
            next_state <= S_COPY_OUTPUT;
            next_out_data <= out_array;
        end
        S_COPY_OUTPUT: begin
            copy_cnt <= 0;
            for (i = 0; i < N; i = i + 1) begin
                out_array[i] <= out_data[(N-1)-i];
                copy_cnt <= copy_cnt + 1;
            end
            next_state <= S_DONE;
            next_done <= 1'b1;
        end
        S_DONE: begin
            done <= next_done;
            next_state <= S_IDLE;
        end
    endcase
end
