// Combinational Logic Optimization
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        done <= 1'b0;
        out_data <= {N*WIDTH{1'b0}};
        base_idx <= 0;
        left_idx <= 0;
        right_idx <= 0;
        merge_idx <= 0;
        subarray_size <= 1;
    end else begin
        case (state)
            IDLE: begin
                state <= LOAD;
            end
            LOAD: begin
                for (i = 0; i < N; i = i + 1) begin
                    data_mem[i] <= in_data[i*WIDTH +: WIDTH];
                end
                base_idx <= 0;
                left_idx <= 0;
                right_idx <= 0;
                merge_idx <= 0;
                subarray_size <= 1;
                state <= SORT;
            end
            // Other states remain unchanged
            ...
        endcase
    end
end

// Sequential Logic Optimization
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset logic remains unchanged
    end else begin
        case (state)
            IDLE: begin
                state <= LOAD;
            end
            LOAD: begin
                // Load logic remains unchanged
            end
            SORT: begin
                if (subarray_size >= N) begin
                    state <= DONE;
                end else begin
                    state <= MERGE;
                end
            end
            MERGE: begin
                // Merge logic with combined conditions and single register for temp values
                ...
            end
            DONE: begin
                for (i = 0; i < N; i = i + 1) begin
                    out_data[i*WIDTH +: WIDTH] <= data_mem[i];
                end
                state <= IDLE; // Directly assign to IDLE to avoid unnecessary state transition
            end
            ...
        endcase
    end
end
