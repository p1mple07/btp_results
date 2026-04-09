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

    // Arrays get "shadow copies" for combinational updates
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
    integer rev_idx;
    reg [WIDTH-1:0]     val;
    reg [$clog2(N):0]   pos;

    integer i;
    
    // Combinational logic: compute next state and next values
    always @(*) begin
        // Default assignments: copy current registers
        next_state         = current_state;
        next_load_cnt      = load_cnt;
        next_find_cnt      = find_cnt;
        next_count_cnt     = count_cnt;
        next_prefix_cnt    = prefix_cnt;
        next_build_cnt     = build_cnt;
        next_copy_cnt      = copy_cnt;
        next_max_val       = max_val;
        next_done          = 1'b0;
        next_out_data      = out_data;
        
        // Default: copy arrays
        for (i = 0; i < N; i = i + 1) begin
            next_data_array[i] = data_array[i];
            next_out_array[i]  = out_array[i];
        end
        for (i = 0; i < (1<<WIDTH); i = i + 1) begin
            next_count_array[i] = count_array[i];
        end
        
        case (current_state)
            S_IDLE: begin
                if (start) begin
                    next_state         = S_LOAD_INPUT;
                    next_load_cnt      = 0;
                    // Reset other counters
                    next_find_cnt      = 0;
                    next_count_cnt     = 0;
                    next_prefix_cnt    = 0;
                    next_build_cnt     = 0;
                    next_copy_cnt      = 0;
                end
            end
            
            S_LOAD_INPUT: begin
                next_load_cnt = load_cnt + 1;
                // Copy existing data_array then update the current index with new slice from in_data
                for (i = 0; i < N; i = i + 1)
                    next_data_array[i] = data_array[i];
                next_data_array[load_cnt] = in_data[WIDTH*(load_cnt+1)-1 -: WIDTH];
                if (load_cnt == N-1)
                    next_state = S_FIND_MAX;
                else
                    next_state = S_LOAD_INPUT;
            end
            
            S_FIND_MAX: begin
                next_find_cnt = find_cnt + 1;
                // Update max_val if current element is greater
                if (data_array[find_cnt] > max_val)
                    next_max_val = data_array[find_cnt];
                else
                    next_max_val = max_val;
                if (find_cnt == N-1)
                    next_state = S_COUNT;
                else
                    next_state = S_FIND_MAX;
            end
            
            S_COUNT: begin
                next_count_cnt = count_cnt + 1;
                // Copy current histogram then increment count for current element
                for (i = 0; i < (1<<WIDTH); i = i + 1)
                    next_count_array[i] = count_array[i];
                val = data_array[count_cnt];
                next_count_array[val] = count_array[val] + 1;
                if (count_cnt == N-1)
                    next_state = S_PREFIX_SUM;
                else
                    next_state = S_COUNT;
            end
            
            S_PREFIX_SUM: begin
                next_prefix_cnt = prefix_cnt + 1;
                // Copy current histogram then update cumulative sum at current index
                for (i = 0; i < (1<<WIDTH); i = i + 1)
                    next_count_array[i] = count_array[i];
                if (prefix_cnt == 0)
                    next_count_array[0] = count_array[0];
                else
                    next_count_array[prefix_cnt] = count_array[prefix_cnt] + count_array[prefix_cnt-1];
                if (prefix_cnt == max_val)
                    next_state = S_BUILD_OUTPUT;
                else
                    next_state = S_PREFIX_SUM;
            end
            
            S_BUILD_OUTPUT: begin
                next_build_cnt = build_cnt + 1;
                // Determine index in data_array to process (iterate from last to first)
                rev_idx = N - 1 - build_cnt;
                val = data_array[rev_idx];
                pos = count_array[val];
                // Place the value in the correct position in out_array
                next_out_array[pos - 1] = val;
                // Decrement the count in the histogram
                next_count_array[val] = count_array[val] - 1;
                if (build_cnt == N-1)
                    next_state = S_COPY_OUTPUT;
                else
                    next_state = S_BUILD_OUTPUT;
            end
            
            S_COPY_OUTPUT: begin
                next_copy_cnt = copy_cnt + 1;
                // Pack out_array into out_data bus
                next_out_data = {N*WIDTH{1'b0}};
                for (i = 0; i < N; i = i + 1)
                    next_out_data((i+1)*WIDTH-1:i*WIDTH) = out_array[i];
                if (copy_cnt == N-1)
                    next_state = S_DONE;
                else
                    next_state = S_COPY_OUTPUT;
            end
            
            S_DONE: begin
                next_done = 1'b1;
                next_state = S_IDLE;
            end
            
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // Sequential logic: update state and registers on clock edge
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
            for (i = 0; i < (1<<WIDTH); i = i + 1)
                count_array[i] <= {($clog2(N)+1){1'b0}};
        end else begin
            current_state <= next_state;
            load_cnt      <= next_load_cnt;
            find_cnt      <= next_find_cnt;
            count_cnt     <= next_count_cnt;
            prefix_cnt    <= next_prefix_cnt;
            build_cnt     <= next_build_cnt;
            copy_cnt      <= next_copy_cnt;
            max_val       <= next_max_val;
            done          <= next_done;
            out_data      <= next_out_data;
            
            // Update arrays
            for (i = 0; i < N; i = i + 1) begin
                data_array[i] <= next_data_array[i];
                out_array[i]  <= next_out_array[i];
            end
            for (i = 0; i < (1<<WIDTH); i = i + 1)
                count_array[i] <= next_count_array[i];
        end
    end

endmodule