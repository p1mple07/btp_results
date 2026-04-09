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
    reg [$clog2(N)-1:0] i;  // Current element index
    reg [$clog2(N)-1:0] pos; // Position to insert current element

    // Wires for comparison and swap
    wire [WIDTH-1:0] val_j;

    assign val_j  = array[i];

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                // Insert current element into sorted subarray
                for (int k = 0; k < i; k = k + 1) begin
                    if (array[k] > val_j) begin
                        array[k+1] <= array[k];
                    end else begin
                        pos <= k;
                        break;
                    end
                end
                array[pos] <= val_j;
                
                // Update indices
                i <= i + 1;
                if (i == N) begin
                    next_state = DONE;
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

    // FSM: Output and counter updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i <= 0;
            pos <= 0;
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
                        pos <= 0;
                    end
                end

                SORTING: begin
                    // Perform insertion sort
                    for (int k = 0; k < N; k = k + 1) begin
                        val_j <= array[k];
                        i <= k;
                        while (i > 0 && array[i-1] > val_j) begin
                            array[i] <= array[i-1];
                            i <= i - 1;
                        end
                        array[0] <= val_j;
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