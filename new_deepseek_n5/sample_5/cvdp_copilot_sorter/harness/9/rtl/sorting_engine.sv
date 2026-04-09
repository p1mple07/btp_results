module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input wire                clk,
    input wire                rst,
    input wire                start,
    input wire [N*WIDTH-1:0] in_data,
    output reg                done,
    output reg [N*WIDTH-1:0] out_data
);
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;

    reg [1:0] state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [ (log2(N/2+1)) -1 : 0 ] pair_idx;
    reg [ (log2(N+1)) -1 : 0 ] pass_cnt;

    wire [ (log2(N/2+1)) -1 : 0 ] pairs_in_this_pass;

    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ( (N/2) > 0 ? (N/2) - 1 : 0 );

    // Initialize data array
    initial begin
        data_array = { {in_data[0]}, {in_data[1]}, ..., {in_data[N-1]} };
    end

    // State machine
    always_comb begin
        if (rst) begin
            state = IDLE;
            next_state = IDLE;
        end else if (start) begin
            state = LOAD;
            next_state = SORT;
        end else if (state == SORT) begin
            // Even pass: compare even-odd pairs
            if (pass_cnt[0] % 2 == 0) begin
                for (int i = 0; i < N/2; i++, pass_cnt[0]++) begin
                    if (data_array[2*i] > data_array[2*i+1]) begin
                        // Swap
                        reg [WIDTH-1:0] temp = data_array[2*i];
                        data_array[2*i] = data_array[2*i+1];
                        data_array[2*i+1] = temp;
                        next_state = SORT;
                    end
                end
            end else begin
                // Odd pass: compare odd-even pairs
                for (int i = 1; i < N/2; i++, pass_cnt[0]++) begin
                    if (data_array[2*i+1] > data_array[2*i]) begin
                        // Swap
                        reg [WIDTH-1:0] temp = data_array[2*i+1];
                        data_array[2*i+1] = data_array[2*i];
                        data_array[2*i] = temp;
                        next_state = SORT;
                    end
                end
            end
            if (pass_cnt[0] == N) begin
                // After all passes, done
                state = DONE;
                next_state = DONE;
            end else begin
                // Transition back to SORT state
                state = SORT;
                next_state = SORT;
            end
        end
    end

    // Final transition to DONE
    always_comb begin
        if (state == DONE) begin
            next_state = DONE;
        else if (state == SORT && pass_cnt[0] == N) begin
            state = DONE;
            next_state = DONE;
        end
    end

    wire done_state;
    assign next_state = done_state;

    // Output the sorted data
    wire [N*WIDTH-1:0] out_data;
    always begin
        out_data = data_array;
    end
endmodule