module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
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
    reg [WIDTH-1:0] val;
    reg [$clog2(N):0] pos;

    integer i;
    always @(*) begin
        // State transition logic
        case (current_state)
            S_IDLE:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 1;
                    next_state = S_LOAD_INPUT;
                else begin
                    current_state = S_LOAD_INPUT;
                end
                next_state = S_LOAD_INPUT;
                break;
            S_LOAD_INPUT:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 0;
                    next_state = S_LOAD_INPUT;
                else begin
                    data_array[load_cnt] = in_data[load_cnt];
                    load_cnt++;
                    if (load_cnt == N) {
                        current_state = S_FIND_MAX;
                    }
                end
                next_state = S_FIND_MAX;
                break;
            S_FIND_MAX:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 0;
                    next_state = S_LOAD_INPUT;
                else begin
                    max_val = data_array[0];
                    find_cnt = 1;
                    next_state = S_COUNT;
                end
                next_state = S_COUNT;
                break;
            S_COUNT:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 0;
                    next_state = S_LOAD_INPUT;
                else begin
                    count_array[max_val] = 0;
                    count_cnt = 0;
                    next_state = S_PREFIX_SUM;
                end
                next_state = S_PREFIX_SUM;
                break;
            S_PREFIX_SUM:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 0;
                    next_state = S_LOAD_INPUT;
                else begin
                    count_array[0] = 0;
                    prefix_cnt = 0;
                    next_state = S_BUILD_OUTPUT;
                end
                next_state = S_BUILD_OUTPUT;
                break;
            S_BUILD_OUTPUT:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 0;
                    next_state = S_LOAD_INPUT;
                else begin
                    out_array[build_cnt] = data_array[build_cnt];
                    build_cnt++;
                    if (build_cnt == N) {
                        current_state = S_COPY_OUTPUT;
                    }
                end
                next_state = S_COPY_OUTPUT;
                break;
            S_COPY_OUTPUT:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 0;
                    next_state = S_LOAD_INPUT;
                else begin
                    next_out_array = out_array;
                    copy_cnt = 0;
                    next_state = S_DONE;
                end
                next_state = S_DONE;
                break;
            S_DONE:
                if (rst) begin
                    current_state = S_IDLE;
                    done = 0;
                    out_data = {N*WIDTH{1'b0}};
                    max_val = {WIDTH{1'b0}};
                    load_cnt = 0;
                    next_state = S_LOAD_INPUT;
                else begin
                    next_state = S_IDLE;
                    done = 1;
                end
                next_state = S_IDLE;
                break;
        end

        // Update next values
        next_data_array = data_array;
        next_out_array = out_array;
        next_count_array = count_array;
        next_max_val = max_val;
        next_load_cnt = load_cnt;
        next_find_cnt = find_cnt;
        next_count_cnt = count_cnt;
        next_prefix_cnt = prefix_cnt;
        next_build_cnt = build_cnt;
        next_copy_cnt = copy_cnt;
        next_done = done;
        next_out_data = out_data;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= S_IDLE;
            done <= 0;
            out_data <= {N*WIDTH{1'b0}};
            max_val <= {WIDTH{1'b0}};
            load_cnt <= 0;
            find_cnt <= 0;
            count_cnt <= 0;
            prefix_cnt <= 0;
            build_cnt <= 0;
            copy_cnt <= 0;
            for (i = 0; i < N; i = i + 1) begin
                data_array[i] <= {WIDTH{1'b0}};
                out_array[i]  <= {WIDTH{1'b0}};
            end
            for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                count_array[i] <= {($clog2(N)+1){1'b0}};
            end
        end else begin
            current_state <= next_state;
            data_array <= next_data_array;
            out_array <= next_out_array;
            count_array <= next_count_array;
            max_val <= next_max_val;
            load_cnt <= next_load_cnt;
            find_cnt <= next_find_cnt;
            count_cnt <= next_count_cnt;
            prefix_cnt <= next_prefix_cnt;
            build_cnt <= next_build_cnt;
            copy_cnt <= next_copy_cnt;
            done <= next_done;
            out_data <= next_out_data;
        end
    end
endmodule