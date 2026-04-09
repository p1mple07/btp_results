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
    // FSM state encoding
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;

    // Internal registers and arrays
    reg [1:0]  state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [$clog2(N+1)-1:0] pass_cnt;
    reg [$clog2(N/2+1)-1:0] pair_idx;

    // Determine number of comparisons per pass:
    // For even passes (pass_cnt[0] == 0) use N/2 comparisons;
    // For odd passes use (N/2)-1 comparisons.
    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ((N/2) > 0 ? (N/2) - 1 : 0);
   
    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (start)
                    next_state = LOAD;
            LOAD:  next_state = SORT;
            SORT:  if (pass_cnt == N)
                    next_state = DONE;
                  else
                    next_state = SORT;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // FSM sequential process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            done       <= 1'b0;
            pass_cnt   <= 0;
            pair_idx   <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    // Remain idle until start is asserted.
                end
                LOAD: begin
                    // Load the input data into the internal array in one clock cycle.
                    integer i;
                    for (i = 0; i < N; i = i + 1) begin
                        data_array[i] <= in_data[i*WIDTH +: WIDTH];
                    end
                    pass_cnt   <= 0;
                    pair_idx   <= 0;
                    done       <= 1'b0;
                end
                SORT: begin
                    // Perform one compare-and-swap per clock cycle.
                    if (pair_idx < pairs_in_this_pass) begin
                        if (pass_cnt[0] == 1'b0) begin
                            // Even pass: compare and swap even-indexed pairs (0,1), (2,3), ...
                            if (data_array[2*pair_idx] > data_array[2*pair_idx+1]) begin
                                data_array[2*pair_idx] <= data_array[2*pair_idx+1];
                                data_array[2*pair_idx+1] <= data_array[2*pair_idx];
                            end
                        end else begin
                            // Odd pass: compare and swap odd-indexed pairs (1,2), (3,4), ...
                            if (data_array[2*pair_idx+1] > data_array[2*pair_idx+2]) begin
                                data_array[2*pair_idx+1] <= data_array[2*pair_idx+2];
                                data_array[2*pair_idx+2] <= data_array[2*pair_idx+1];
                            end
                        end
                        pair_idx <= pair_idx + 1;
                    end else begin
                        // End of current pass; move to the next pass.
                        pass_cnt <= pass_cnt + 1;
                        pair_idx <= 0;
                    end
                end
                DONE: begin
                    // Pack the sorted data into out_data and assert done for one clock cycle.
                    integer j;
                    for (j = 0; j < N; j = j + 1)
                        out_data[j*WIDTH +: WIDTH] <= data_array[j];
                    done <= 1'b1;
                end
                default: begin
                    // No operation.
                end
            endcase
        end
    end

endmodule