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

    // Variables for bubble sort indexing
    reg [$clog2(N)-1:0] i;  // Outer loop index
    reg [$clog2(N)-1:0] j;  // Inner loop index

    // Wires for comparison and swap
    wire [WIDTH-1:0] val_j;
    wire [WIDTH-1:0] val_j1;

    assign val_j  = array[j];
    assign val_j1 = array[j+1];

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                // Insertion sort
                for (integer i = 1; i < N; i = i + 1) begin
                    reg [WIDTH-1:0] key;
                    reg [WIDTH-1:0] j;
                    for (j = i-1; j >= 0; j = j - 1) begin
                        if (array[j] > array[j+1]) begin
                            array[j+1] = array[j];
                            array[j] = key;
                        end else break;
                    end
                end
            end
            DONE: begin
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
