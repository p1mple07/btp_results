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
    
    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            state <= IDLE;
            pass_cnt <= 0;
            pair_idx <= 0;
        end
        else
        begin
            case (state)
                IDLE:
                begin
                    if (start)
                        state <= LOAD;
                end
                
                LOAD:
                begin
                    for (int i=0; i<N; i++)
                    begin
                        data_array[i] <= in_data[i*WIDTH+(WIDTH-1):i*WIDTH];
                    end
                    
                    state <= SORT;
                end
                
                SORT:
                begin
                    int j=0;
                    int k=0;

                    for (int i=0; i<(N-1)/2; i++)
                    begin
                        while (k < N && data_array[k][WIDTH-1:0] < data_array[j][WIDTH-1:0])
                            j++;
                            
                        while (k < N && data_array[k][WIDTH-1:0] >= data_array[j][WIDTH-1:0])
                            k++;
                            
                        if (j!= k)
                        begin
                            int temp[0:WIDTH-1];

                            for (int l=0; l<WIDTH; l++)
                            begin
                                temp[l] <= data_array[k][l].
                                data_array[k][l] <= data_array[j][l].
                            end
                        end
                        
                    end
                    
                    state <= DONE;
                end
                
                DONE:
                begin
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
            
            pass_cnt <= {pair_idx, '0'};
        end
    end
endmodule