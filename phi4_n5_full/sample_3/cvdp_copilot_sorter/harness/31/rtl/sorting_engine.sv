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
    reg [WIDTH-1:0]     val;
    reg [$clog2(N):0]   pos;

    integer i;
    
    // Combinational logic for FSM
    always @(*) begin
        // Default: pass through current values
        next_state       = current_state;
        next_done        = done;
        next_load_cnt    = load_cnt;
        next_find_cnt    = find_cnt;
        next_count_cnt   = count_cnt;
        next_prefix_cnt  = prefix_cnt;
        next_build_cnt   = build_cnt;
        next_copy_cnt    = copy_cnt;
        next_max_val     = max_val;
        next_out_data    = out_data;
        
        // Copy arrays by default
        integer k;
        for (k = 0; k < N; k = k + 1) begin
            next_data_array[k] = data_array[k];
            next_out_array[k]  = out_array[k];
        end
        for (k = 0; k < (1<<WIDTH); k = k + 1) begin
            next_count_array[k] = count_array[k];
        end

        case (current_state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_LOAD_INPUT;
                    next_load_cnt = 0;
                end
            end
            S_LOAD_INPUT: begin
                if (load_cnt < N) begin
                    next_load_cnt = load_cnt + 1;
                    // Unpack one element from in_data into data_array at index load_cnt
                    next_data_array[load_cnt] = in_data[load_cnt*WIDTH +: WIDTH];
                end else begin
                    next_state = S_FIND_MAX;
                    next_find_cnt = 0;
                    next_max_val = 0;
                end
            end
            S_FIND_MAX: begin
                if (find_cnt < N) begin
                    next_find_cnt = find_cnt + 1;
                    if (data_array[find_cnt] > max_val)
                        next_max_val = data_array[find_cnt];
                    else
                        next_max_val = max_val;
                end else begin
                    next_state = S_COUNT;
                    next_count_cnt = 0;
                end
            end
            S_COUNT: begin
                if (count_cnt < N) begin
                    next_count_cnt = count_cnt + 1;
                    next_count_array[data_array[count_cnt]] = count_array[data_array[count_cnt]] + 1;
                end else begin
                    next_state = S_PREFIX_SUM;
                    next_prefix_cnt = 0;
                end
            end
            S_PREFIX_SUM: begin
                if (prefix_cnt < max_val) begin
                    next_prefix_cnt = prefix_cnt + 1;
                    // For prefix sum: update count_array[i+1] = count_array[i] + count_array[i+1]
                    if (prefix_cnt == 0)
                        next_count_array[1] = count_array[0] + count_array[1];
                    else
                        next_count_array[prefix_cnt] = count_array[prefix_cnt] + count_array[prefix_cnt - 1];
                end else begin
                    next_state = S_BUILD_OUTPUT;
                    next_build_cnt = 0;
                end
            end
            S_BUILD_OUTPUT: begin
                if (build_cnt < N) begin
                    next_build_cnt = build_cnt + 1;
                    integer idx;
                    idx = N - build_cnt - 1;
                    pos = count_array[data_array[idx]] - 1;
                    next_out_array[pos] = data_array[idx];
                    next_count_array[data_array[idx]] = count_array[data_array[idx]] - 1;
                end else begin
                    next_state = S_COPY_OUTPUT;
                    next_copy_cnt = 0;
                end
            end
            S_COPY_OUTPUT: begin
                if (copy_cnt < 1) begin
                    next_copy_cnt = copy_cnt + 1;
                    next_out_data = 0;
                    integer j;
                    // Pack out_array into out_data (LSB corresponds to out_array[0])
                    for (j = 0; j < N; j = j + 1) begin
                        next_out_data = { next_out_array[j], next_out_data };
                    end
                end else begin
                    next_state = S_DONE;
                end
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

    // Sequential logic for FSM
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
            integer idx;
            for (idx = 0; idx < N; idx = idx + 1) begin
                data_array[idx] <= {WIDTH{1'b0}};
                out_array[idx]  <= {WIDTH{1'b0}};
            end
            for (idx = 0; idx < (1<<WIDTH); idx = idx + 1) begin
                count_array[idx] <= {($clog2(N)+1){1'b0}};
            end
        end else begin
            current_state <= next_state;
            done          <= next_done;
            out_data      <= next_out_data;
            load_cnt      <= next_load_cnt;
            find_cnt      <= next_find_cnt;
            count_cnt     <= next_count_cnt;
            prefix_cnt    <= next_prefix_cnt;
            build_cnt     <= next_build_cnt;
            copy_cnt      <= next_copy_cnt;
            max_val       <= next_max_val;
            integer k;
            for (k = 0; k < N; k = k