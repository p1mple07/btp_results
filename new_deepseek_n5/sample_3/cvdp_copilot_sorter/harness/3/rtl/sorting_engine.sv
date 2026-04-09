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
    reg [2:0]  current_pos;  // Current position to insert

    // Variables for insertion sort
    reg [WIDTH-1:0] temp;    // Temporary register for comparison

    // Wires for comparison and swap
    wire [WIDTH-1:0] val_j;

    assign val_j  = array[current_pos];

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
                if (current_pos == N-1)
                    next_state = DONE;
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

    // FSM: Output and counter updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            current_pos <= 0;
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
                        current_pos <= 0;
                    end
                    next_state <= IDLE;
                end

                SORTING: begin
                    // Find the correct position for current element
                    for (int pos = current_pos; pos < N-1; pos = pos + 1) begin
                        // Compare current element with next element
                        if (array[pos] > array[pos+1]) begin
                            // Swap elements
                            temp <= array[pos];
                            array[pos] <= array[pos+1];
                            array[pos+1] <= temp;
                        end
                    end
                    current_pos <= pos;
                    next_state <= IDLE;
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