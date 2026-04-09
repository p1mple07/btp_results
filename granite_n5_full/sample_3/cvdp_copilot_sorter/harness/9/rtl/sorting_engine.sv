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
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0)? (N/2) : ( (N/2) > 0? (N/2) - 1 : 0 );
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            pass_cnt <= 0;
            pair_idx <= 0;
            for (int i=0; i<N; i++) begin
                data_array[i] <= 0;
            end
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    for (int i=0; i<N; i++) begin
                        data_array[i] <= in_data[(i*WIDTH)+(WIDTH-1):(i*WIDTH)];
                    end
                    state <= SORT;
                    pass_cnt <= 0;
                    pair_idx <= 0;
                end
                SORT: begin
                    int j;
                    for (j=0; j<pairs_in_this_pass; j++) begin
                        if (j==0 || pair_idx>=pairs_in_this_pass) begin
                            pair_idx <= 0;
                        end
                        if (pair_idx>=pairs_in_this_pass) begin
                            state <= DONE;
                        end
                        data_array[pair_idx] <= in_data[(pair_idx*WIDTH)+(WIDTH-1):(pair_idx*WIDTH)];
                        if (pair_idx<(pairs_in_this_pass-1)) begin
                            pair_idx <= pair_idx + 1;
                        end
                        else begin
                            state <= DONE;
                        end
                    end
                END
                DONE: begin
                    out_data <= data_array;
                    done <= 1'b1;
                end
            endcase
        end
    end

endmodule