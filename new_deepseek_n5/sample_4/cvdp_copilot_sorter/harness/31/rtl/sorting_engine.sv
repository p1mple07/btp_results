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

    localparam [3:0]
        S_IDLE         = 4'd0,
        S_LOAD_INPUT   = 4'd1,
        S_FIND_MAX     = 4'd2,
        S_COUNT        = 4'd3,
        S_PREFIX_SUM   = 4'd4,
        S_BUILD_OUTPUT = 4'd5,
        S_COPY_OUTPUT  = 4'd6,
        S_DONE         = 4'd7;

    reg [3:0]           current_state;
    reg [WIDTH-1:0]     data_array [0:N-1];
    reg [WIDTH-1:0]     out_array  [0:N-1];
    reg [$clog2(N):0]   count_array[0:(1<<WIDTH)];
    reg [WIDTH-1:0]     max_val;

    always @(*) begin
        case(current_state)
            S_IDLE:
                if (start) begin
                    current_state = S_LOAD_INPUT;
                    data_array = in_data;
                end
                default:
                    current_state = S_IDLE;
                    break;
            S_LOAD_INPUT:
                next_data_array = data_array;
                next_state = S_FIND_MAX;
                next_max_val = 0;
                next_count_array = count_array;
                next_find_cnt = 0;
                next_count_cnt = 0;
                next_build_cnt = 0;
                next_copy_cnt = 0;
                next_done = 0;
                next_out_data = out_data;
                for (i = 0; i < N; i = i + 1) begin
                    count_array[data_array[i]] = count_array[data_array[i]] + 1;
                end
                current_state = S_FIND_MAX;
                break;
            S_FIND_MAX:
                next_data_array = data_array;
                next_state = S_COUNT;
                next_max_val = max_val;
                next_count_array = count_array;
                next_find_cnt = find_cnt + 1;
                next_count_cnt = count_cnt;
                next_build_cnt = build_cnt;
                next_copy_cnt = copy_cnt;
                next_done = done;
                next_out_data = out_data;
                max_val = data_array[0];
                for (i = 1; i < N; i = i + 1) begin
                    if (data_array[i] > max_val) begin
                        max_val = data_array[i];
                    end
                end
                current_state = S_COUNT;
                break;
            S_COUNT:
                next_data_array = data_array;
                next_state = S_PREFIX_SUM;
                next_max_val = max_val;
                next_count_array = count_array;
                next_find_cnt = find_cnt;
                next_count_cnt = count_cnt + 1;
                next_build_cnt = build_cnt;
                next_copy_cnt = copy_cnt;
                next_done = done;
                next_out_data = out_data;
                for (i = max_val; i > 0; i = i - 1) begin
                    count_array[i] = count_array[i] + count_array[i + 1];
                end
                current_state = S_PREFIX_SUM;
                break;
            S_PREFIX_SUM:
                next_data_array = data_array;
                next_state = S_BUILD_OUTPUT;
                next_max_val = max_val;
                next_count_array = count_array;
                next_find_cnt = find_cnt;
                next_count_cnt = count_cnt;
                next_build_cnt = build_cnt + 1;
                next_copy_cnt = copy_cnt;
                next_done = done + 1;
                next_out_data = out_data;
                for (i = N - 1; i >= 0; i = i - 1) begin
                    val = data_array[i];
                    pos = count_array[val];
                    out_array[pos] = val;
                    count_array[val] = count_array[val] - 1;
                end
                current_state = S_BUILD_OUTPUT;
                break;
            S_BUILD_OUTPUT:
                next_data_array = data_array;
                next_state = S_COPY_OUTPUT;
                next_max_val = max_val;
                next_count_array = count_array;
                next_find_cnt = find_cnt;
                next_count_cnt = count_cnt;
                next_build_cnt = build_cnt;
                next_copy_cnt = copy_cnt + 1;
                next_done = done;
                next_out_data = out_data;
                for (i = 0; i < N; i = i + 1) begin
                    out_data[i] = out_array[i];
                end
                current_state = S_COPY_OUTPUT;
                break;
            S_COPY_OUTPUT:
                next_data_array = data_array;
                next_state = S_DONE;
                next_max_val = max_val;
                next_count_array = count_array;
                next_find_cnt = find_cnt;
                next_count_cnt = count_cnt;
                next_build_cnt = build_cnt;
                next_copy_cnt = copy_cnt;
                next_done = done + 1;
                next_out_data = out_data;
                current_state = S_DONE;
                break;
            S_DONE:
                next_data_array = data_array;
                next_state = S_IDLE;
                next_max_val = max_val;
                next_count_array = count_array;
                next_find_cnt = find_cnt;
                next_count_cnt = count_cnt;
                next_build_cnt = build_cnt;
                next_copy_cnt = copy_cnt;
                next_done = done;
                next_out_data = out_data;
                current_state = S_IDLE;
                break;
        end
    end

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
            for (i = 0; i < N; i = i + 1) begin
                data_array[i] <= {WIDTH{1'b0}};
                out_array[i]  <= {WIDTH{1'b0}};
            end
            for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                count_array[i] <= {($clog2(N)+1){1'b0}};
            end
        end else begin
            next_state = current_state;
            next_data_array = data_array;
            next_out_array = out_array;
            next_count_array = count_array;
            next_max_val = max_val;
            next_find_cnt = find_cnt;
            next_count_cnt = count_cnt;
            next_build_cnt = build_cnt;
            next_copy_cnt = copy_cnt;
            next_done = done;
            next_out_data = out_data;
        end
    end
endmodule