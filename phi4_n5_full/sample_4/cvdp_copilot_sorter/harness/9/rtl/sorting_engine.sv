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
    reg [WIDTH-1:0] temp;

    // Determine number of comparisons in current pass.
    // Even pass (pass_cnt[0] == 0): N/2 comparisons.
    // Odd pass: N/2 - 1 comparisons.
    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ((N/2) > 0 ? (N/2) - 1 : 0);

    // Next state combinational logic.
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:    next_state = (start) ? LOAD : IDLE;
            LOAD:    next_state = SORT;
            SORT:    next_state = (pass_cnt < N) ? SORT : DONE;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Sequential state machine and processing logic.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            done        <= 1'b0;
            pass_cnt    <= 0;
            pair_idx    <= 0;
            // out_data remains uninitialized at reset.
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    done <= 1'b0;
                end
                LOAD: begin
                    // Load the input array into data_array.
                    integer i;
                    for (i = 0; i < N; i = i + 1) begin
                        data_array[i] <= in_data[(i+1)*WIDTH-1 -: WIDTH];
                    end
                end
                SORT: begin
                    if (pair_idx < pairs_in_this_pass) begin
                        // Even-numbered pass: compare even-odd pairs.
                        if (pass_cnt[0] == 1'b0) begin
                            if (data_array[2*pair_idx] > data_array[2*pair_idx + 1]) begin
                                temp = data_array[2*pair_idx];
                                data_array[2*pair_idx] <= data_array[2*pair_idx + 1];
                                data_array[2*pair_idx + 1] <= temp;
                            end
                        end
                        // Odd-numbered pass: compare odd-even pairs.
                        else begin
                            if (data_array[2*pair_idx + 1] > data_array[2*pair_idx + 2]) begin
                                temp = data_array[2*pair_idx + 1];
                                data_array[2*pair_idx + 1] <= data_array[2*pair_idx + 2];
                                data_array[2*pair_idx + 2] <= temp;
                            end
                        end
                        pair_idx <= pair_idx + 1;
                    end else begin
                        // End of current pass: update pass_cnt and reset pair_idx.
                        if (pass_cnt == N - 1)
                            pass_cnt <= N; // Force exit from SORT state next cycle.
                        else begin
                            pass_cnt <= pass_cnt + 1;
                            pair_idx <= 0;
                        end
                    end
                end
                DONE: begin
                    // Assert done signal for one cycle and pack sorted array into out_data.
                    done <= 1'b1;
                    integer j;
                    out_data <= 0;
                    for (j = 0; j < N; j = j + 1) begin
                        out_data[(j+1)*WIDTH-1 -: WIDTH] <= data_array[j];
                    end
                end
                default: begin
                    done <= 1'b0;
                end
            endcase
        end
    end

endmodule