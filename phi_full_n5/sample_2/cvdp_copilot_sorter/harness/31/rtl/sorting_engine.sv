// Insert code here to implement the combinational logic for the FSM of the Counting sort algorithm.
always @(*) begin
    if (start && !rst) begin
        current_state <= S_LOAD_INPUT;
        load_cnt      <= N;
        next_state    <= S_FIND_MAX;
    end else begin
        current_state <= next_state;
    end
end

// State: S_LOAD_INPUT
always @(posedge clk) begin
    if (current_state == S_LOAD_INPUT) begin
        for (i = 0; i < N; i = i + 1) begin
            data_array[i] <= in_data[i*WIDTH +: WIDTH];
        end
        next_state <= S_FIND_MAX;
    end
end

// State: S_FIND_MAX
always @(posedge clk) begin
    if (current_state == S_FIND_MAX) begin
        max_val <= 0;
        find_cnt  <= 0;
        next_state <= S_COUNT;
        for (i = 0; i < N; i = i + 1) begin
            if (data_array[i] > max_val) begin
                max_val <= data_array[i];
                next_max_val <= max_val;
            end
        end
    end
end

// State: S_COUNT
always @(posedge clk) begin
    if (current_state == S_COUNT) begin
        count_cnt <= 0;
        next_state <= S_PREFIX_SUM;
        for (i = 0; i < (1<<WIDTH); i = i + 1) begin
            if (max_val == i) begin
                count_array[i] <= 0;
            end else begin
                count_array[i] <= count_array[i] + (data_array == max_val);
            end
        end
    end
end

// State: S_PREFIX_SUM
always @(posedge clk) begin
    if (current_state == S_PREFIX_SUM) begin
        prefix_cnt <= 0;
        next_state <= S_BUILD_OUTPUT;
        prefix_cnt <= count_array;
    end
end

// State: S_BUILD_OUTPUT
always @(posedge clk) begin
    if (current_state == S_BUILD_OUTPUT) begin
        build_cnt <= 0;
        next_state <= S_COPY_OUTPUT;
        for (i = N-1; i >= 0; i = i - 1) begin
            out_array[i] <= (count_array == prefix_cnt) ? (data_array +: WIDTH) : {WIDTH{1'b0}};
        end
    end
end

// State: S_COPY_OUTPUT
always @(posedge clk) begin
    if (current_state == S_COPY_OUTPUT) begin
        copy_cnt <= 0;
        next_state <= S_DONE;
        next_out_data <= out_array;
    end
end

// State: S_DONE
always @(posedge clk) begin
    if (current_state == S_DONE) begin
        done <= 1'b1;
        next_state <= S_IDLE;
    end
end

// State: S_IDLE
always @(posedge clk) begin
    if (current_state == S_IDLE) begin
        if (start && !rst) begin
            current_state <= S_LOAD_INPUT;
            load_cnt      <= N;
        end else begin
            current_state <= S_IDLE;
        end
    end
end
