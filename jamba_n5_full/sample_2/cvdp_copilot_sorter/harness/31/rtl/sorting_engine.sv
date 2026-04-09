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

    // State machine
    localparam [3:0] S_IDLE        = 4'd0,
                   S_LOAD_INPUT   = 4'd1,
                   S_FIND_MAX     = 4'd2,
                   S_COUNT        = 4'd3,
                   S_PREFIX_SUM   = 4'd4,
                   S_BUILD_OUTPUT = 4'd5,
                   S_COPY_OUTPUT  = 4'd6,
                   S_DONE         = 4'd7;

    reg [3:0] current_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [WIDTH-1:0] out_array  [0:N-1];
    reg [$clog2(N):0] count_array[0:(1<<WIDTH)-1];
    reg [$clog2(N):0] prefix_cnt;
    reg [$clog2(N):0] build_cnt;
    reg [$clog2(N):0] copy_cnt;
    reg [$clog2(N):0] load_cnt;
    reg [$clog2(N):0] find_cnt;
    reg [$clog2(N):0] count_cnt;
    reg [$clog2(N):0] prefix_sum;
    reg [$clog2(N):0] build_sum;

    reg [WIDTH-1:0] max_val;
    reg load_done;
    reg found;
    reg done_pulse;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= S_IDLE;
            done <= 1'b0;
            out_data <= {N*WIDTH{1'b0}};
            max_val <= {WIDTH{1'b0}};
            load_done <= 1'b0;
            found <= 1'b0;
            done_pulse <= 1'b0;
        end else begin
            current_state <= S_LOAD_INPUT;
            if (start) begin
                load_done <= 1'b1;
                found <= 1'b0;
            end
            else begin
                found <= 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (current_state == S_LOAD_INPUT) begin
            data_array[:] = in_data;
            max_val = {WIDTH{1'b0}};
            for (i = 0; i < N; i=i+1) begin
                max_val = max(max_val, data_array[i]);
            end
        end else if (current_state == S_FIND_MAX) begin
            for (i = N-1; i >= 0; i=i-1) begin
                if (data_array[i] > max_val) max_val = data_array[i];
            end
            found <= 1'b1;
        end else if (current_state == S_COUNT) begin
            for (i = 0; i < N; i=i+1) begin
                count_array[data_array[i]] = count_array[data_array[i]] + 1;
            end
        end else if (current_state == S_PREFIX_SUM) begin
            for (i = 1; i < (1<<WIDTH); i=i+1) begin
                count_array[i] = count_array[i] + count_array[i-1];
            end
        end else if (current_state == S_BUILD_OUTPUT) begin
            for (i = N-1; i >= 0; i=i-1) begin
                out_array[count_array[data_array[i]] - 1] = data_array[i];
                count_array[data_array[i]] = count_array[data_array[i]] - 1;
            end
        end else if (current_state == S_COPY_OUTPUT) begin
            for (i = 0; i < N; i=i+1) begin
                out_data[i] = out_array[i];
            end
        end else if (current_state == S_DONE) begin
            done <= 1'b1;
        end
    end

endmodule
