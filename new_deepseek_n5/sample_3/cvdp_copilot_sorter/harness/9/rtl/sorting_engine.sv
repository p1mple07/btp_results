module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0] in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0] out_data
)
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;
    reg [1:0] state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [ (log2(N/2)+1)-1 : 0 ] pair_idx;
    wire [ (log2(N/2)+1)-1 : 0 ] pairs_in_this_pass;

    assign pairs_in_this_pass = (state[1] == 1'b0) ? (N/2) : ( (N/2) > 0 ? (N/2) - 1 : 0 );

    // Load data
    always @ (start) begin
        if (rst) begin
            data_array = { data_array[0:0], data_array[1:0] };
        end
        data_array = in_data;
    end

    // Sort data
    always @ (posedge clk) begin
        if (rst) next_state = IDLE;
        else if (state == IDLE) begin
            state = LOAD;
            next_state = LOAD;
        elsif (state == LOAD) begin
            state = SORT;
            next_state = SORT;
        elsif (state == SORT) begin
            // Even pass
            if (state[1] == 0) begin
                for (pair_idx = 0; pair_idx < N/2; pair_idx++, state = next_state) {
                    if (data_array[2*pair_idx] > data_array[2*pair_idx+1]) {
                        data_array[2*pair_idx], data_array[2*pair_idx+1] = data_array[2*pair_idx+1], data_array[2*pair_idx];
                    }
                }
                next_state = SORT;
            end
            // Odd pass
            else begin
                for (pair_idx = 0; pair_idx < (N/2)-1; pair_idx++, state = next_state) {
                    if (data_array[2*pair_idx+1] > data_array[2*pair_idx+2]) {
                        data_array[2*pair_idx+1], data_array[2*pair_idx+2] = data_array[2*pair_idx+2], data_array[2*pair_idx+1];
                    }
                }
                next_state = DONE;
            end
        end
        state = next_state;
    end

    // Pack sorted data
    always @ (posedge clk) begin
        if (rst) begin
            out_data = 0;
            done = 0;
        end
        else if (state == DONE) begin
            out_data = data_array;
            done = 1;
        end
        else begin
            out_data = data_array;
        end
    end