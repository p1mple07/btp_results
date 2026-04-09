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
   
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            pair_idx <= 0;
            pass_cnt <= 0;
            out_data <= {N{1'b0}};
            done <= 0;
        end else if (start) begin
            state <= LOAD;
            pair_idx <= 0;
            pass_cnt <= 0;
            data_array <= in_data;
            done <= 0;
        end else if (state == IDLE) begin
            state <= LOAD;
        end else if (state == LOAD) begin
            pair_idx <= $random;
            state <= SORT;
        end else if (state == SORT) begin
            if (pair_idx == pairs_in_this_pass) begin
                if (pass_cnt == N - 1) begin
                    state <= DONE;
                end else begin
                    state <= SORT;
                    pass_cnt <= pass_cnt + 1;
                    pair_idx <= pair_idx + (N/2) - (pass_cnt - 1) * (N/2);
                end
            end else begin
                int i = pair_idx;
                int j = pair_idx + 1;
                if (data_array[i] > data_array[j]) begin
                    wire temp = data_array[i];
                    data_array[i] = data_array[j];
                    data_array[j] = temp;
                end
                state <= SORT;
                pair_idx <= pair_idx + 1;
            end
        end else if (state == DONE) begin
            state <= IDLE;
            out_data <= data_array;
            done <= 1;
        end
    end
endmodule
