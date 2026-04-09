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
    reg [WIDTH-1:0] val;
    reg [$clog2(N):0] pos;

    integer i;
    always @(*) begin
        if (start) begin
            current_state <= S_LOAD_INPUT;
            load_cnt <= load_cnt + 1;
            data_array[load_cnt-1] <= in_data[load_cnt-1];
        end else if (current_state == S_LOAD_INPUT) begin
            find_cnt <= find_cnt + 1;
            max_val <= (data_array[find_cnt-1] > max_val ? data_array[find_cnt-1] : max_val);
        end else if (current_state == S_FIND_MAX) begin
            count_cnt <= count_cnt + 1;
            count_array[max_val] <= count_array[max_val] + 1;
            current_state <= S_PREFIX_SUM;
        end else if (current_state == S_PREFIX_SUM) begin
            prefix_cnt <= prefix_cnt + 1;
            count_array[count_array[0]-1] <= count_array[count_array[0]-1] - 1;
            current_state <= S_BUILD_OUTPUT;
        end else if (current_state == S_BUILD_OUTPUT) begin
            build_cnt <= build_cnt + 1;
            out_array[build_cnt-1] <= data_array[build_cnt-1];
            current_state <= S_COPY_OUTPUT;
        end else if (current_state == S_COPY_OUTPUT) begin
            copy_cnt <= copy_cnt + 1;
            next_out_data[copy_cnt-1] <= out_array[0];
            done <= 1;
            current_state <= S_IDLE;
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
        current_state <= S_IDLE;
    end
end