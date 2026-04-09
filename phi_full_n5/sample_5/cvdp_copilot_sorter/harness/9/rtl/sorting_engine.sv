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

    // Load state
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            pair_idx <= 0;
            pass_cnt <= 0;
        end else if (start) begin
            state <= LOAD;
            pair_idx <= 0;
            pass_cnt <= 0;
        end else if (state == IDLE) begin
            state <= LOAD;
        end
    end

    // Load data
    always @(posedge clk) begin
        if (state == LOAD) begin
            data_array <= in_data;
            pair_idx <= 0;
            pass_cnt <= 0;
            state <= SORT;
        end
    end

    // Sorting state
    always @(posedge clk) begin
        if (state == SORT) begin
            if (pair_idx == pairs_in_this_pass) begin
                // Even-Odd Pass
                if (pass_cnt[0] == 1'b0) begin
                    for (int i = 0; i < N/2; i = i + 2) begin
                        if (data_array[i] > data_array[i+1]) begin
                            wire temp = data_array[i];
                            data_array[i] = data_array[i+1];
                            data_array[i+1] = temp;
                        end
                    end
                    pass_cnt <= pass_cnt + 1;
                end else begin
                    // Odd-Even Pass
                    for (int i = 1; i < N-1; i = i + 2) begin
                        if (data_array[i] > data_array[i+1]) begin
                            wire temp = data_array[i];
                            data_array[i] = data_array[i+1];
                            data_array[i+1] = temp;
                        end
                    end
                    pass_cnt <= pass_cnt + 1;
                end
                if (pass_cnt == N) begin
                    state <= DONE;
                    out_data <= data_array;
                    done <= 1'b1;
                end
            end else begin
                pair_idx <= pair_idx + 1;
            end
        end
    end

    // Done state
    always @(posedge clk) begin
        if (state == DONE) begin
            state <= IDLE;
            out_data <= data_array;
            done <= 1'b1;
        end
    end

endmodule
