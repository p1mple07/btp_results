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
    // Insertion sort implementation here

    // FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0]  state, next_state;

    // Variables for insertion sort indexing
    reg [$clog2(N)-1:0] i;  // Current index being sorted
    reg [$clog2(N)-1:0] j;  // Index of the element to be inserted

    // Wires for comparison and swap
    wire [WIDTH-1:0] val_i;
    wire [WIDTH-1:0] val_j;

    assign val_i = in_data[(i+1)*WIDTH-1 -: WIDTH];
    assign val_j = in_data[(j+1)*WIDTH-1 -: WIDTH];

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                // Transition to DONE once all elements are sorted
                if (i == (N-1) && j == 0)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // FSM: Output and counter updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            done <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Load the array from in_data
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i <= 0;
                        j <= 0;
                    end
                end

                SORTING: begin
                    // Perform a single comparison and swap if needed
                    if (val_i > val_j) begin
                        array[j]   <= val_i;
                        array[j+1] <= val_j;
                    }

                    // Update j
                    if (j == N-2) begin
                        // One pass completed, increment i
                        j <= 0;
                        i <= i + 1;
                    end else begin
                        j <= j + 1;
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
                end
            endcase
        end
    end

endmodule