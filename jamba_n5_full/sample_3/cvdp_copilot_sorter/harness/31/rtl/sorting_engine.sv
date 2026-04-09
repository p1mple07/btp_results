module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [N*WIDTH-1:0] in_data,
    output reg [N*WIDTH-1:0] out_data
);

localparam [3:0] S_IDLE = 4'd0,
             S_LOAD_INPUT = 4'd1,
             S_FIND_MAX = 4'd2,
             S_COUNT = 4'd3,
             S_PREFIX_SUM = 4'd4,
             S_BUILD_OUTPUT = 4'd5,
             S_COPY_OUTPUT = 4'd6,
             S_DONE = 4'd7;

reg [3:0] current_state;
reg [WIDTH-1:0] data_array [0:N-1];
reg [WIDTH-1:0] out_array [0:N-1];
reg [$clog2(N):0] count_array[0:(1<<WIDTH)-1];
reg [$clog2(N):0] max_val;
reg [$clog2(N):0] load_cnt;
reg [$clog2(N):0] find_cnt;
reg [$clog2(N):0] count_cnt;
reg [WIDTH-1:0] prefix_cnt;
reg [$clog2(N):0] build_cnt;
reg [$clog2(N):0] copy_cnt;

initial begin
    current_state = S_IDLE;
    data_array[0:N-1] = {WIDTH{1'b0}};
    out_array[0:N-1] = {WIDTH{1'b0}};
    count_array[0:(1<<WIDTH)-1] = {$clog2(N)+1{1'b0}};
end

always @(posedge clk or posedge rst) begin
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
    end else begin
        case (current_state)
            S_IDLE: begin
                // idle
            end
            S_LOAD_INPUT: begin
                for (i = 0; i < N*WIDTH; i++) data_array[i] = in_data[i];
                end
            end
            S_FIND_MAX: begin
                max_val = data_array[N*WIDTH-1];
                end
            end
            S_COUNT: begin
                for (i = 0; i < N; i++) begin
                    val = data_array[i];
                    count_array[val]++;
                end
                end
            end
            S_PREFIX_SUM: begin
                for (i = 0; i < (1<<WIDTH); i++) begin
                    if (i > 0) count_array[i] = count_array[i] + count_array[i-1];
                end
                end
            end
            S_BUILD_OUTPUT: begin
                for (i = N*WIDTH-1; i >= 0; i--) begin
                    out_array[i] = count_array[data_array[i]] - 1;
                    count_array[data_array[i]]--;
                end
                end
            end
            S_COPY_OUTPUT: begin
                for (i = 0; i < N*WIDTH; i++) out_data[i] = data_array[i];
                end
            end
            default: begin
                // no action
            end
        endcase
    end
end

endmodule
