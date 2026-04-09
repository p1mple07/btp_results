rtl/sorting_engine.sv
--------------------------------------------------
module sorting_engine #(
    parameter N     = 8,     
    parameter WIDTH  = 8  
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    // FSM states
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;

    // FSM registers and data array
    reg [1:0]  state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [$clog2(N+1)-1:0] pass_cnt;
    reg [$clog2(N/2+1)-1:0] pair_idx;
    reg [WIDTH-1:0] temp;

    // Determine number of comparisons in the current pass:
    // For even passes (pass_cnt[0]==0): N/2 comparisons.
    // For odd passes: (N/2)-1 comparisons.
    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ((N/2) > 0 ? (N/2) - 1 : 0);

    // FSM sequential logic.
    // Note: This implementation uses blocking assignments for the compare-swap operation
    // so that the swap occurs within the same clock cycle.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            pass_cnt   <= 0;
            pair_idx   <= 0;
            done       <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state     = LOAD;
                        pass_cnt  = 0;
                        pair_idx  = 0;
                    end
                end

                LOAD: begin
                    // Load the input array into data_array in one clock cycle.
                    integer i;
                    for (i = 0; i < N; i = i + 1) begin
                        data_array[i] = in_data[i*WIDTH +: WIDTH];
                    end
                    state     = SORT;
                    pass_cnt  = 0;
                    pair_idx  = 0;
                end

                SORT: begin
                    // Perform one compare-and-swap per clock cycle.
                    if (pass_cnt[0] == 1'b0) begin
                        // Even pass: compare even-indexed pairs (0,1), (2,3), ...
                        if (data_array[2*pair_idx] > data_array[2*pair_idx+1]) begin
                            temp       = data_array[2*pair_idx];
                            data_array[2*pair_idx] = data_array[2*pair_idx+1];
                            data_array[2*pair_idx+1] = temp;
                        end
                    end
                    else begin
                        // Odd pass: compare odd-indexed pairs (1,2), (3,4), ...
                        if (data_array[2*pair_idx+1] > data_array[2*pair_idx+2])