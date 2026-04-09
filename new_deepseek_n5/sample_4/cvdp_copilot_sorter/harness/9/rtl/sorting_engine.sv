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
    reg [3:0]   pass_cnt;
    reg [3:0]   pair_idx;

    wire [3:0] pairs_in_this_pass;

    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (4) : (3 > 0 ? 3 : 0);

    always @posedge rst) begin
        state = IDLE;
    end

    always @posedge start) begin
        if (rst) begin
            state = IDLE;
            data_array = { {0} };
        end else begin
            if (state == IDLE) begin
                state = LOAD;
                data_array = in_data;
            end else if (state == LOAD) begin
                state = SORT;
            end else if (state == SORT) begin
                for (pass_cnt = 0; pass_cnt < N; pass_cnt = pass_cnt + 1) begin
                    pair_idx = 0;
                    if (pass_cnt % 2 == 0) begin
                        for (pair_idx = 0; pair_idx < N/2; pair_idx = pair_idx + 1) begin
                            if (data_array[2*pair_idx] > data_array[2*pair_idx + 1]) begin
                                data_array[2*pair_idx] = data_array[2*pair_idx + 1];
                                data_array[2*pair_idx + 1] = data_array[2*pair_idx];
                            end
                        end
                    else begin
                        for (pair_idx = 0; pair_idx < N/2 - 1; pair_idx = pair_idx + 1) begin
                            if (data_array[2*pair_idx + 1] > data_array[2*pair_idx + 2]) begin
                                data_array[2*pair_idx + 1] = data_array[2*pair_idx + 2];
                                data_array[2*pair_idx + 2] = data_array[2*pair_idx + 1];
                            end
                        end
                    end
                end
                state = DONE;
            end
        end
    end

    always @posedge clock) begin
        if (state == SORT) begin
            pass_cnt = pass_cnt + 1;
        end
    end

    // Output the sorted data
    out_data = data_array;
    done = 1'd0;
endmodule