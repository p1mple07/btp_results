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

    // State machine states
    localparam [3:0]
        S_IDLE        = 4'd0,
        S_LOAD_INPUT  = 4'd1,
        S_FIND_MAX    = 4'd2,
        S_COUNT       = 4'd3,
        S_PREFIX_SUM  = 4'd4,
        S_BUILD_OUTPUT= 4'd5,
        S_COPY_OUTPUT = 4'd6,
        S_DONE        = 4'd7;

    // Counters
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [WIDTH-1:0] out_array  [0:N-1];
    reg [$clog2(N):0] count_array[0:(1<<WIDTH)-1];

    reg [WIDTH-1:0] max_val;
    reg [$clog2(N):0] load_cnt;
    reg [$clog2(N):0] find_cnt;
    reg [$clog2(N):0] count_cnt;
    reg [WIDTH-1:0] prefix_cnt;
    reg [$clog2(N):0] build_cnt;
    reg [$clog2(N):0] copy_cnt;

    // Next state
    reg [3:0] next_state;

    // Next data
    reg [WIDTH-1:0] next_data_array [0:N-1];

    integer i;

    always @(*) begin
        next_state = S_IDLE;

        if (current_state == S_IDLE) begin
            next_state = S_LOAD_INPUT;
        end else if (current_state == S_LOAD_INPUT) begin
            next_state = S_FIND_MAX;
        end else if (current_state == S_FIND_MAX) begin
            next_state = S_COUNT;
        end else if (current_state == S_COUNT) begin
            next_state = S_PREFIX_SUM;
        end else if (current_state == S_PREFIX_SUM) begin
            next_state = S_BUILD_OUTPUT;
        end else if (current_state == S_BUILD_OUTPUT) begin
            next_state = S_COPY_OUTPUT;
        end else if (current_state == S_COPY_OUTPUT) begin
            next_state = S_DONE;
        end else if (current_state == S_DONE) begin
            next_state = S_IDLE;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= S_IDLE;
            done <= 1'b0;
            out_data <= {N*WIDTH{1'b0}};
            max_val <= {WIDTH{1'b0}};

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
            next_data_array[N-1] = data_array[N-1];
            next_out_array[N-1] = out_array[N-1];
            next_count_array[N-1] = count_array[N-1];

            // But this might be too complex.

            // Instead, we can just follow the earlier logic.

        end
    end

    // After processing, output the sorted data
    always @(*) begin
        if (current_state == S_COPY_OUTPUT) begin
            for (i = 0; i < N; i = i + 1) begin
                out_array[i] = next_out_array[i];
            end
            done <= 1'b1;
        end else if (current_state == S_BUILD_OUTPUT) begin
            for (i = N-1; i >= 0; i = i - 1) begin
                out_array[i] = data_array[i];
            end
            done <= 1'b1;
        end else if (current_state == S_FIND_MAX) begin
            max_val <= data_array[find_cnt];
        end else if (current_state == S_COUNT) begin
            for (i = 0; i < N; i = i + 1) begin
                count_array[i] <= 0;
            end
            for (j = 0; j < N; j = j + 1) begin
                count_array[next_data_array[j]] <= 1;
            end
        end
    end

endmodule
