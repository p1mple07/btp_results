always @(posedge clk or posedge rst) begin
    if (rst) begin
        // synchronous reset
        current_state <= S_IDLE;
        done          <= 1'b0;
        out_data      <= {N*WIDTH{1'b0}};
        max_val       <= {WIDTH{1'b0}};

        load_cnt      <= 0;
        find_cnt      <= 0;
        count_cnt     <= 0;
        prefix_cnt    <= 0;
        build_cnt     <= 0;
        copy_cnt      <= 0;

        // Clear arrays
        for (i = 0; i < N; i = i + 1) begin
            data_array[i] <= {WIDTH{1'b0}};
            out_array[i]  <= {WIDTH{1'b0}};
        end
        for (i = 0; i < (1<<WIDTH); i = i + 1) begin
            count_array[i] <= {($clog2(N)+1){1'b0}};
        end
    end else begin
        case (current_state)
            S_IDLE: begin
                if (start) begin
                    current_state <= S_LOAD_INPUT;
                end else begin
                    current_state <= S_IDLE;
                end
            end
            S_LOAD_INPUT: begin
                if (!start) begin
                    current_state <= S_IDLE;
                end else begin
                    for (i = 0; i < N; i = i + 1) begin
                        data_array[i] <= in_data[i*WIDTH +: WIDTH];
                    end
                    next_data_array <= data_array;
                    load_cnt <= N;
                    next_load_cnt <= N;
                    next_state <= S_FIND_MAX;
                end
            end
            S_FIND_MAX: begin
                max_val <= {WIDTH{data_array[N-1]}};
                next_max_val <= max_val;
                next_state <= S_COUNT;
            end
            S_COUNT: begin
                count_array <= {(1<<WIDTH)-1'b0, 0};
                for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                    count_array[i] <= count_array[i] + (next_data_array[i] == next_max_val);
                end
                next_count_array <= count_array;
                find_cnt <= N;
                next_state <= S_PREFIX_SUM;
            end
            S_PREFIX_SUM: begin
                prefix_cnt <= {$clog2(N)+1{1'b0}};
                for (i = 0; i < prefix_cnt; i = i + 1) begin
                    count_array[i] <= count_array[i] + count_array[i+1];
                end
                next_prefix_cnt <= prefix_cnt;
                next_state <= S_BUILD_OUTPUT;
            end
            S_BUILD_OUTPUT: begin
                build_cnt <= N;
                for (i = 0; i < N; i = i + 1) begin
                    out_array[i] <= (count_array[count_array[i]] == count_array[0]) ? (max_val - 1) : (max_val);
                end
                next_out_array <= out_array;
                copy_cnt <= N;
                next_state <= S_COPY_OUTPUT;
            end
            S_COPY_OUTPUT: begin
                out_data <= next_out_data;
                next_out_data <= {N*WIDTH{1'b0}};
                copy_cnt <= N;
                next_done <= 1'b0;
                current_state <= S_DONE;
            end
            S_DONE: begin
                done <= next_done;
                next_state <= S_IDLE;
            end
        end
    end
end

always @* begin
    // Combinational logic for state transitions
    next_state = current_state;
    if (current_state == S_IDLE) begin
        next_max_val <= {WIDTH{1'b0}};
        next_load_cnt <= 0;
        next_find_cnt <= 0;
        next_count_cnt <= 0;
        next_prefix_cnt <= 0;
        next_build_cnt <= 0;
        next_copy_cnt <= 0;
        next_done <= 1'b0;
    end else if (current_state == S_LOAD_INPUT) begin
        next_max_val <= max_val;
        next_load_cnt <= load_cnt;
        next_find_cnt <= find_cnt;
        next_count_cnt <= count_cnt;
        next_prefix_cnt <= prefix_cnt;
        next_build_cnt <= build_cnt;
        next_copy_cnt <= copy_cnt;
    end else if (current_state == S_FIND_MAX) begin
        next_max_val <= max_val;
        next_load_cnt <= 1;
        next_find_cnt <= 0;
        next_count_cnt <= 0;
        next_prefix_cnt <= 0;
        next_build_cnt <= 0;
        next_copy_cnt <= 0;
    end else if (current_state == S_COUNT) begin
        next_max_val <= max_val;
        next_load_cnt <= 0;
        next_find_cnt <= 1;
        next_count_cnt <= count_cnt + 1;
        next_prefix_cnt <= 0;
        next_build_cnt <= 0;
        next_copy_cnt <= 0;
    end else if (current_state == S_PREFIX_SUM) begin
        next_max_val <= max_val;
        next_load_cnt <= 0;
        next_find_cnt <= 0;
        next_count_cnt <= count_cnt + 1;
        next_prefix_cnt <= prefix_cnt + 1;
        next_build_cnt <= 0;
        next_copy_cnt <= 0;
    end else if (current_state == S_BUILD_OUTPUT) begin
        next_max_val <= max_val;
        next_load_cnt <= 0;
        next_find_cnt <= 0;
        next_count_cnt <= count_cnt;
        next_prefix_cnt <= prefix_cnt;
        next_build_cnt <= build_cnt + 1;
        next_copy_cnt <= copy_cnt;
    end else if (current_state == S_COPY_OUTPUT) begin
        next_max_val <= max_val;
        next_load_cnt <= 0;
        next_find_cnt <= 0;
        next_count_cnt <= count_cnt;
        next_prefix_cnt <= prefix_cnt;
        next_build_cnt <= 0;
        next_copy_cnt <= copy_cnt + 1;
    end
end
