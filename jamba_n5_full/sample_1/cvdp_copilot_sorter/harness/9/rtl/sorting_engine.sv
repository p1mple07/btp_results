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

    always @(posedge clk or posedge rst) begin
        if (!rst) begin
            state <= IDLE;
            next_state <= IDLE;
            done <= 0;
            out_data <= in_data;
        end else if (state == IDLE) begin
            state <= LOAD;
            next_state <= SORT;
        end else if (state == LOAD) begin
            state <= SORT;
            next_state <= IDLE;
        end else if (state == SORT) begin
            state <= DONE;
            next_state <= LOAD;
        end else begin
            state <= IDLE;
            next_state <= SORT;
        end
    end

    always_ff @(posedge clk) begin
        if (state == SORT) begin
            pass_cnt = 0;
            for (int i = 0; i < N/2; i++) begin
                if (i % 2 == 0) begin
                    for (int j = 0; j < N/2; j++) {
                        int idx1 = 2*j;
                        int idx2 = 2*j+1;
                        if (data_array[idx1] > data_array[idx2]) swap(&data_array[idx1], &data_array[idx2]);
                    }
                } else begin
                    for (int j = 0; j < N/2; j++) {
                        int idx1 = 2*j+1;
                        int idx2 = 2*j;
                        if (data_array[idx1] > data_array[idx2]) swap(&data_array[idx1], &data_array[idx2]);
                    }
                }
                pass_cnt++;
            }
        end
    end

    assign done = 1'b1;
    assign out_data = data_array;

endmodule
