module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input wire                clk,
    input wire                rst,
    input wire                start,
    input wire [N*WIDTH-1:0] in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0] out_data
);
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;

    reg [1:0] state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [$clog2(N+1)-1:0] pass_cnt;
    reg [$clog2(N/2+1)-1:0] pair_idx;

    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ( (N/2) > 0 ? (N/2) - 1 : 0 );

    // State machine logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state = IDLE;
            next_state = IDLE;
        end else if (start) begin
            if (state == IDLE) begin
                state = LOAD;
                next_state = LOAD;
            end else if (state == LOAD) begin
                state = SORT;
                next_state = SORT;
            end else if (state == SORT) begin
                // Implement even-odd sort algorithm
                for (pair_idx = 0; pair_idx < (N/2); pair_idx++) begin
                    if (pass_cnt[0] == 0) begin // Even pass (0,1), (2,3), etc.
                        if (data_array[2*pair_idx] > data_array[2*pair_idx+1]) begin
                            data_array[2*pair_idx] = data_array[2*pair_idx+1];
                            data_array[2*pair_idx+1] = data_array[2*pair_idx];
                        end
                    else begin // Odd pass (1,2), (3,4), etc.
                        if (data_array[2*pair_idx+1] > data_array[2*pair_idx+2]) begin
                            data_array[2*pair_idx+1] = data_array[2*pair_idx+2];
                            data_array[2*pair_idx+2] = data_array[2*pair_idx+1];
                        end
                    end
                end
                pass_cnt[0] = pass_cnt[0] + 1;
                if (pass_cnt[0] == N) begin
                    state = DONE;
                    next_state = DONE;
                end else if (pairs_in_this_pass > 0) begin
                    pairs_in_this_pass = pairs_in_this_pass - 1;
                    next_state = SORT;
                else begin
                    next_state = IDLE;
                end
            end
        end else if (state == DONE) begin
            state = DONE;
            next_state = DONE;
        end
        // Update state
        state = next_state;
    end

    // Initialize done state on last clock cycle of sorting
    always @(posedge clk) begin
        if (state == DONE) begin
            done = 1;
            next_state = DONE;
        end else if (state == SORT && pass_cnt[0] == N) begin
            // Transition to done after sorting completes
            done = 1;
            next_state = DONE;
        end
    end

    // Load data into register
    always @(posedge start or posedge rst) begin
        if (rst) begin
            data_array = (WIDTH-1:0)[0:N-1]({0};
        else if (start) begin
            data_array = in_data;
        end
    end

    // Output data
    always @(posedge clk) begin
        if (state == DONE) begin
            out_data = data_array;
        end
    end
endmodule