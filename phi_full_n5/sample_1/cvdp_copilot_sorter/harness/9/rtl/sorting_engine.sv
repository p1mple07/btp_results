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
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;

    reg [1:0]  state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [$clog2(N+1)-1:0] pass_cnt;
    reg [$clog2(N/2+1)-1:0] pair_idx;

    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ( (N/2) > 0 ? (N/2) - 1 : 0 );

    // Initialize the data array
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_array <= {WIDTH{in_data[0]}};
        end else if (start) begin
            state <= LOAD;
        end
    end

    // State machine
    always @(state, pair_idx) begin
        case (state)
            IDLE: begin
                if (pair_idx == N - 1) begin
                    state <= SORT;
                    pass_cnt <= 0;
                end
            end
            LOAD: begin
                if (pair_idx < N - 1) begin
                    data_array <= {data_array[pair_idx], data_array[pair_idx + 1]};
                    pair_idx <= pair_idx + 1;
                end
            end
            SORT: begin
                if (pass_cnt == N - 1) begin
                    state <= DONE;
                    out_data <= data_array;
                    done <= 1'b1;
                end else if (pair_idx < N - 1) begin
                    case (pair_idx % 2 == 0)
                        0: begin
                            if (data_array[pair_idx] > data_array[pair_idx + 1]) begin
                                data_array[pair_idx] <= data_array[pair_idx + 1];
                                data_array[pair_idx + 1] <= data_array[pair_idx];
                            end
                        end
                        1: begin
                            if (data_array[pair_idx] > data_array[pair_idx + 2]) begin
                                data_array[pair_idx] <= data_array[pair_idx + 2];
                                data_array[pair_idx + 2] <= data_array[pair_idx];
                            end
                        end
                    end
                    pair_idx <= pair_idx + (2 * (pair_idx % 2));
                    pass_cnt <= pass_cnt + 1;
                end
            end
            DONE: begin
                state <= IDLE;
            end
        end
    end
endmodule
