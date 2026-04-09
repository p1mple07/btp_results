module sorting_engine #(
    parameter N = 8,          // number of elements to sort
    parameter WIDTH = 8       // bit-width of each element
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    //-----------------------------------------------------
    // State machine definitions
    //-----------------------------------------------------
    localparam [3:0]
        S_IDLE         = 4'd0,
        S_LOAD_INPUT   = 4'd1,
        S_FIND_MAX     = 4'd2,
        S_COUNT        = 4'd3,
        S_PREFIX_SUM   = 4'd4,
        S_BUILD_OUTPUT = 4'd5,
        S_COPY_OUTPUT  = 4'd6,
        S_DONE         = 4'd7;

    //-----------------------------------------------------
    // Registered signals (updated in sequential always)
    //-----------------------------------------------------
    reg [3:0]           current_state;
    reg [WIDTH-1:0]     data_array [0:N-1];
    reg [WIDTH-1:0]     out_array  [0:N-1];
    reg [$clog2(N):0]   count_array[0:(1<<WIDTH)-1];

    reg [WIDTH-1:0]     max_val;
    reg [$clog2(N):0]   load_cnt;
    reg [$clog2(N):0]   find_cnt;
    reg [$clog2(N):0]   count_cnt;
    reg [WIDTH-1:0]     prefix_cnt;
    reg [$clog2(N):0]   build_cnt;
    reg [$clog2(N):0]   copy_cnt;

    //-----------------------------------------------------
    // Wires/reg for "next" values (computed combinationally)
    //-----------------------------------------------------
    reg [3:0]           next_state;

    reg [WIDTH-1:0]     next_data_array [0:N-1];
    reg [WIDTH-1:0]     next_out_array  [0:N-1];
    reg [$clog2(N):0]   next_count_array[0:(1<<WIDTH)-1];

    reg [WIDTH-1:0]     next_max_val;
    reg [$clog2(N):0]   next_load_cnt;
    reg [$clog2(N):0]   next_find_cnt;
    reg [$clog2(N):0]   next_count_cnt;
    reg [WIDTH-1:0]     next_prefix_cnt;
    reg [$clog2(N):0]   next_build_cnt;
    reg [$clog2(N):0]   next_copy_cnt;

    reg                 next_done;
    reg [N*WIDTH-1:0]   next_out_data;

    integer i, j;

    //-----------------------------------------------------
    // Combinational logic: next state and signal updates
    //-----------------------------------------------------
    always @(*) begin
        // Default assignments: pass through current values
        next_state        = current_state;
        next_done         = done;
        next_load_cnt     = load_cnt;
        next_find_cnt     = find_cnt;
        next_count_cnt    = count_cnt;
        next_prefix_cnt   = prefix_cnt;
        next_build_cnt    = build_cnt;
        next_copy_cnt     = copy_cnt;
        next_max_val      = max_val;
        next_out_data     = out_data;
        
        // Default: copy arrays
        for(i = 0; i < N; i = i + 1) begin
            next_data_array[i] = data_array[i];
            next_out_array[i]  = out_array[i];
        end
        for(j = 0; j < (1<<WIDTH); j = j + 1) begin
            next_count_array[j] = count_array[j];
        end

        case (current_state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_LOAD_INPUT;
                    next_load_cnt = 0;
                    next_find_cnt = 0;
                    next_count_cnt = 0;
                    next_prefix_cnt = 0;
                    next_build_cnt = 0;
                    next_copy_cnt = 0;
                    next_max_val = {WIDTH{1'b0}};
                end
            end

            S_LOAD_INPUT: begin
                next_load_cnt = load_cnt + 1;
                // Load one element from in_data into data_array
                next_data_array[load_cnt] = in_data[WIDTH*(load_cnt+1)-1 : WIDTH*load_cnt];
                if (load_cnt == N-1)
                    next_state = S_FIND_MAX;
            end

            S_FIND_MAX: begin
                next_find_cnt = find_cnt + 1;
                // Update max_val based on current element
                if (data_array[find_cnt] > max_val)
                    next_max_val = data_array[find_cnt];
                else
                    next_max_val = max_val;
                if (find_cnt == N-1)
                    next_state = S_COUNT;
            end

            S_COUNT: begin
                next_count_cnt = count_cnt + 1;
                // Increment histogram for the current element
                next_count_array[data_array[count_cnt]] = count_array[data_array[count_cnt]] + 1;
                if (count_cnt == N-1)
                    next_state = S_PREFIX_SUM;
            end

            S_PREFIX_SUM: begin
                // If max_val is 0, no elements greater than 0 exist; transition immediately.
                if (max_val == 0) begin
                    next_state = S_BUILD_OUTPUT;
                end else if (prefix_cnt < max_val) begin
                    next_prefix_cnt = prefix_cnt + 1;
                    // Cumulative sum: count_array[j+1] = count_array[j+1] + count_array[j]
                    next_count_array[prefix_cnt + 1] = count_array[prefix_cnt + 1] + count_array[prefix_cnt];
                    if (prefix_cnt + 1 == max_val)
                        next_state = S_BUILD_OUTPUT;
                end
            end

            S_BUILD_OUTPUT: begin
                next_build_cnt = build_cnt + 1;
                // Process elements in reverse order (to preserve stability)
                j = N - 1 - build_cnt;
                // Place element into out_array at the position indicated by the histogram
                next_out_array[ count_array[data_array[j]] - 1 ] = data_array[j];
                // Decrement the histogram count for this value
                next_count_array[data_array[j]] = count_array[data_array[j]] - 1;
                if (build_cnt == N-1)
                    next_state = S_COPY_OUTPUT;
            end

            S_COPY_OUTPUT: begin
                // Pack the sorted array (out_array) into the packed bus out_data.
                // Concatenate out_array elements so that out_data[WIDTH*(i+1)-1:WIDTH*i] = out_array[i].
                next_out_data = 0;
                for(i = 0; i < N; i = i + 1) begin
                    next_out_data = { next_out_data, out_array[i] };
                end
                next_copy_cnt = 0;
                next_state = S_DONE;
            end

            S_DONE: begin
                next_state = S_IDLE;
                next_done = 1'b1;
            end

            default: next_state = S_IDLE;
        endcase
    end

    //-----------------------------------------------------
    // Sequential logic: update registers on clock edge
    //-----------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
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
            for (j = 0; j < (1<<WIDTH); j = j + 1) begin
                count_array[j] <= {($clog2(N)+1){1'b0}};
            end
        end else begin
            current_state <= next_state;
            load_cnt      <= next_load_cnt;
            find_cnt      <= next_find_cnt;
            count_cnt     <= next_count_cnt;
            prefix_cnt    <= next_prefix_cnt;
            build_cnt     <= next_build_cnt;
            copy_cnt      <= next_copy_cnt;
            max_val       <= next_max_val;
            out_data      <= next_out_data;
            done          <= next_done;

            // Update arrays
            for (i = 0; i < N; i = i + 1) begin
                data_array[i] <= next_data_array[i];
                out_array[i]  <= next_out_array[i];
            end
            for (j = 0; j < (1<<WIDTH); j = j + 1) begin
                count_array[j] <= next_count_array[j];
            end
        end
    end

endmodule