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
    
    always @ (posedge clk or posedge rst)
    begin
        if (rst)
        begin
            state <= IDLE;
            pass_cnt <= '0;
            pair_idx <= '0;
        end
        else
        begin
            state <= next_state;

            case (state)
                IDLE:
                begin
                    if (start)
                    begin
                        next_state <= LOAD;
                    end
                    else
                    begin
                        next_state <= IDLE;
                    end
                end

                LOAD:
                begin
                    next_state <= SORT;
                    for (int i=0; i<N; i++)
                    begin
                        data_array[i] <= in_data[(i*WIDTH)+:WIDTH];
                    end
                end

                SORT:
                begin
                    int num_pairs = N/2;
                    int num_comparisons = 0;

                    next_state <= DONE;

                    for (int p=0; p<num_pairs; p++)
                    begin
                        pair_idx <= '0;

                        while (pair_idx < num_pairs-1)
                        begin
                            pair_idx <= pair_idx + 1;
                            int pos1 = (pair_idx)*WIDTH;
                            int pos2 = (pair_idx+1)*WIDTH;

                            if (data_array[pos1:pos1+WIDTH-1:pos1:pos1+WIDTH-1])
                                data_array[pos2:pos2+WIDTH-1:pos2+WIDTH-1].
                            else 
                                data_array[pos1:pos1+WIDTH-1:pos1+WIDTH-1] <= data_array[pos2:pos2+WIDTH-1:pos2+WIDTH-1].
                        end
                    end

                    DONE:
                    begin
                        next_state <= IDLE;
                        out_data <= in_data;
                        done <= 1;
                    end
                end
            endcase
        end
    endmodule