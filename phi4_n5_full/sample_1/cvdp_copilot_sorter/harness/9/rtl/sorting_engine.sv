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

    // Define FSM states
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;

    reg [1:0] state;
    reg [WIDTH-1:0] data_array [0:N-1];
    // pass_cnt counts the current pass (0 to N-1)
    reg [$clog2(N+1)-1:0] pass_cnt;
    // pair_idx counts the current comparison in the pass
    reg [$clog2(N/2+1)-1:0] pair_idx;

    // For even-numbered passes (pass_cnt[0]==0) we have N/2 comparisons.
    // For odd-numbered passes, we have (N/2 - 1) comparisons.
    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ((N/2) - 1);

    // Synchronous state machine
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            pass_cnt      <= 0;
            pair_idx      <= 0;
            done          <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start)
                        state <= LOAD;
                    // Remain in IDLE until start is asserted.
                end

                LOAD: begin
                    // Load the input data into the internal array.
                    // Each element is WIDTH bits wide.
                    integer i;
                    for (i = 0; i < N; i = i + 1) begin
                        data_array[i] <= in_data[WIDTH*(i+1)-1 -: WIDTH];
                    end
                    pass_cnt <= 0;
                    pair_idx <= 0;
                    state    <= SORT;
                end

                SORT: begin
                    // In each clock cycle, perform one compare-and-swap.
                    if (pair_idx < pairs_in_this_pass) begin
                        // Even pass: compare even-indexed pairs.
                        if (pass_cnt[0] == 1'b0) begin
                            if (data_array[2*pair_idx] < data_array[2*pair_idx+1]) begin
                                reg [WIDTH-1:0] temp;
                                temp = data_array[2*pair_idx];
                                data_array[2*pair_idx] <= data_array[2*pair_idx+1];
                                data_array[2*pair_idx+1] <= temp;
                            end
                        end
                        // Odd pass: compare odd-indexed pairs.
                        else begin
                            if (data_array[2*pair_idx+1] < data_array[2*pair_idx+2]) begin
                                reg [WIDTH-1:0] temp;
                                temp = data_array[2*pair_idx+1];
                                data_array[2*pair_idx+1] <= data_array[2*pair_idx+2];
                                data_array[2*pair_idx+2] <= temp;
                            end
                        end
                        pair_idx <= pair_idx + 1;
                    end
                    else begin
                        // End of current pass: move to next pass or finish.
                        if (pass_cnt < N-1) begin
                            pass_cnt <= pass_cnt + 1;
                            pair_idx <= 0;
                        end
                        else begin
                            // Last pass complete; move to DONE state.
                            state <= DONE;
                        end
                    end
                end

                DONE: begin
                    // Pack the sorted array into out_data.
                    // According to the latency example, the sorted order is descending:
                    // the largest element goes to the MSB.
                    integer i;
                    reg [N*WIDTH-1:0] temp_out;
                    temp_out = 0;
                    for (i = 0; i < N; i = i + 1) begin
                        temp_out = {temp_out, data_array[N-1-i]};
                    end
                    out_data <= temp_out;
                    done     <= 1;  // Assert done for one clock cycle.
                    state    <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule