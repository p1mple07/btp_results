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

    // Variables for insertion sort
    reg [$clog2(N)-1:0] i;  // Outer loop index
    reg [$clog2(N)-1:0] j;  // Inner loop index
    reg [$clog2(N)-1:0] k;  // Temporary index for shifting

    // Wires for comparison and swap
    wire [WIDTH-1:0] val_j;
    wire [WIDTH-1:0] val_j1;

    assign val_j  = array[j];
    assign val_j1 = array[j+1];

    assign val_j1 = array[j+1]; // Actually we already have val_j1 = array[j+1] from val_j1 assignment above? Let's re-evaluate.

    Actually, we should have:

    assign val_j1 = val_j; // Wait, we need to keep consistency.

    Let's just keep the earlier approach but simplify.

    We'll create a for loop for j from 1 to N-1.

    In the SORTING state, we do:

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                // Insertion sort logic
                for (j = 1; j < N; j++) begin
                    val_j = array[j];
                    val_j1 = array[j-1];
                    if (val_j < val_j1) begin
                        // Shift elements to the right
                        for (k = j-1; k >= 0; k--) begin
                            if (array[k] > array[k+1])
                                array[k+1] <= array[k];
                        end
                        array[j] <= array[j-1];
                    end
                end
                done <= 1;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
