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
    reg [$clog2(N/2+1)-1:0] pass_cnt;
    reg [$clog2(N/2+1)-1:0] pair_idx;

    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ( (N/2) > 0 ? (N/2) - 1 : 0 );

    // Initialize data array and done signal
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            data_array <= {N{1'b0}};
            done <= 1'b0;
        end else if (start && state == IDLE) begin
            state <= LOAD;
            data_array <= in_data;
            done <= 1'b0;
        end
    end

    // State machine
    always @ (state) begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= LOAD;
                end else begin
                    state <= DONE;
                end
            end
            LOAD: begin
                if (data_array[pair_idx] > data_array[pair_idx + 1]) begin
                    state <= SORT;
                    pair_idx <= pair_idx + 1;
                end else begin
                    state <= DONE;
                end
            end
            SORT: begin
                pass_cnt <= pass_cnt + 1;
                if (pair_idx == (N/2) - 1) begin
                    state <= DONE;
                end else begin
                    pair_idx <= pair_idx + 1;
                    state <= SORT;
                end
            end
            DONE: begin
                out_data <= data_array;
                done <= 1'b1;
            end
        end
    end

    // Update state machine on clock edges
    always @ (posedge clk) begin
        next_state <= state;
        if (rst) next_state <= IDLE;
    end

endmodule
