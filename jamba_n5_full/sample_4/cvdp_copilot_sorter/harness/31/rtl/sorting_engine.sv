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

    reg                 next_state;

    integer rev_idx;
    reg [WIDTH-1:0] val;
    reg [$clog2(N):0] pos;

    integer i;

    always @(*) begin
        current_state <= S_IDLE;

        if (rst) begin
            current_state <= S_IDLE;
            done <= 1'b0;
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
            }
            for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                count_array[i] <= {($clog2(N)+1){1'b0}};
            }

        end else begin

            // Get current state
            case (current_state)
                0: begin
                    // S_IDLE: wait for start
                    if (start) begin
                        next_state <= S_LOAD_INPUT;
                    end
                end
                1: begin
                    // S_LOAD_INPUT: read start
                    if (start) begin
                        next_state <= S_FIND_MAX;
                    end
                end
                2: begin
                    // S_FIND_MAX: find max in in_data
                    if (start) begin
                        max_val <= in_data[N-1];
                        next_state <= S_COUNT;
                    end else begin
                        max_val <= max(data_array);
                        next_state <= S_COUNT;
                    end
                end
                3: begin
                    // S_COUNT: count occurrences
                    for (i = 0; i < N; i = i + 1) begin
                        if (data_array[i] == max_val) begin
                            count_array[max_val] <= count_array[max_val] + 1;
                        end else begin
                            count_array[data_array[i]] <= count_array[data_array[i]] + 1;
                        end
                    end
                    next_state <= S_PREFIX_SUM;
                end
                4: begin
                    // S_PREFIX_SUM: cumulative sum
                    for (i = 0; i < max_val; i = i + 1) begin
                        count_array[i] <= count_array[i] + count_array[i+1];
                    end
                    next_state <= S_BUILD_OUTPUT;
                end
                5: begin
                    // S_BUILD_OUTPUT: build output
                    for (i = max_val; i >= 0; i = i - 1) begin
                        out_array[i] = count_array[i] * WIDTH;
                        count_array[i] -= 1;
                        if (count_array[i] > 0) count_array[i] <= count_array[i] + WIDTH;
                    end
                    next_state <= S_COPY_OUTPUT;
                end
                6: begin
                    // S_COPY_OUTPUT: copy to out_data
                    for (i = 0; i < N*WIDTH; i = i + 1) begin
                        val <= out_array[i];
                        out_data[i*WIDTH + WIDTH-1] = val[WIDTH-1];
                        out_data[i*WIDTH] = val[WIDTH-2];
                    end
                    next_state <= S_DONE;
                end
                7: begin
                    // S_DONE: assert done
                    done <= 1'b1;
                end
            endcase

        end
    end

endmodule
