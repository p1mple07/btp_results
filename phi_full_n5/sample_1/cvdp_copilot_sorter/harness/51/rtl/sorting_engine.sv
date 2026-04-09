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

    // Optimized FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0]  state, next_state;

    // Optimized variables for bubble sort indexing
    reg [N-1:0] index_pair; // Pair of indices for comparison

    // Comparison and swap wires
    wire [WIDTH-1:0] val_j, val_j1;

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                // Perform a single comparison and swap if needed
                val_j = array[index_pair[0]];
                val_j1 = array[index_pair[1]];
                if (val_j > val_j1) begin
                    array[index_pair[0]] <= array[index_pair[1]];
                    array[index_pair[1]] <= val_j;
                end
                // Update index_pair
                index_pair <= index_pair + 2'd1;
                if (index_pair == N-1) begin
                    // One pass completed, reset index_pair
                    index_pair <= index_pair - 2'd1;
                    // Increment i
                    i <= i + 1;
                end
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
            index_pair <= 3'd0;
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
                        index_pair <= 3'd0;
                    end
                end

                SORTING: begin
                    if (i == N-1) begin
                        done <= 1;
                        // Output the sorted data
                        for (int m = 0; m < N; m = m + 1) begin
                            out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                        end
                    end
                    // Increment i
                    i <= i + 1;
                end
                DONE: begin
                    // Sorting complete
                    done <= 1;
                end
                default: begin
                end
            endcase
        end
    end

endmodule
