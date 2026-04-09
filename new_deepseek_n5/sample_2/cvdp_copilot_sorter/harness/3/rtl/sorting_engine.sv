module sorting_engine #(
    parameter N = 8,             // Number of elements to sort
    parameter WIDTH = 8          // Bit-width of each element
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    // Internal registers to hold the array
    reg [WIDTH-1:0] array [0:N-1];

    // FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0]  state, next_state;
    reg [1:0]  i, pos;  // Insertion sort indices

    // Variables for insertion sort indexing
    reg [$clog2(N)-1:0] i;  // Outer loop index
    reg [$clog2(N)-1:0] pos; // Position to insert current element

    // Wires for comparison and swap
    wire [WIDTH-1:0] val_j;

    assign val_j  = array[pos];

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                // Transition to DONE once all passes are complete
                if (i == (N-1)) begin
                    pos = 0;
                    // Insert current element into sorted subarray
                    while (pos > 0 && array[pos-1] > val_j) begin
                        array[pos] = array[pos-1];
                        pos = pos - 1;
                    end
                    array[pos] = val_j;
                    i = i + 1;
                end
            end
            DONE: begin
                // Sorting complete
                done <= 1;
                // Output the sorted data
                for (int m = 0; m < N; m = m + 1) begin
                    out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    endmodule