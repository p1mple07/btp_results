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

    reg [1:0] state, next_state;

    // Registers for insertion sort indexing
    // i: current element index (from 1 to N-1)
    // j: index used for shifting elements in the sorted portion
    reg [$clog2(N)-1:0] i;
    reg [$clog2(N)-1:0] j;
    // Temporary register to hold the key element being inserted
    reg [WIDTH-1:0] key;

    // Phase for the insertion sort steps within the SORTING state:
    //  0: Setup phase - load key and initialize j
    //  1: Shifting phase - shift elements greater than key one position right
    //  2: Insertion phase - insert key into correct position and move to next element
    reg [1:0] phase;

    // Next state combinational logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
                else
                    next_state = IDLE;
            end
            SORTING: begin
                // When all elements have been processed (i == N-1), move to DONE
                if (i == N-1)
                    next_state = DONE;
                else
                    next_state = SORTING;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Sequential logic: state transitions and insertion sort main logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            i          <= 0;
            j          <= 0;
            done       <= 0;
            phase      <= 2'd0;
            key        <= '0;
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
                        // Start insertion sort with element index 1 (element at index 0 is already sorted)
                        i <= 1;
                        phase <= 2'd0;
                    end
                end

                SORTING: begin
                    // Insertion sort logic implemented via the phase variable
                    case (phase)
                        2'd0: begin
                            // Setup phase: load the key and initialize j = i - 1
                            key <= array[i];
                            j   <= i - 1;
                            phase <= 2'd1;
                        end
                        2'd1: begin
                            // Shifting phase: if there is an element to compare and it is greater than key, shift it right
                            if (j >= 0 && array[j] > key) begin
                                array[j+1] <= array[j];
                                j <= j - 1;
                                // Remain in shifting phase for another comparison/shift
                                phase <= 2'd1;
                            end else begin
                                // Exit shifting phase when the correct insertion point is found
                                phase <= 2'd2;
                            end
                        end
                        2'd2: begin
                            // Insertion phase: insert the key at the found position
                            array[j+1] <= key;
                            // Move to the next element to be inserted
                            i <= i + 1;
                            if (i < N-1) begin
                                // Prepare for the next element: reset phase to setup
                                phase <= 2'd0;
                            end else begin
                                // When the last element is processed, remain here so that the next cycle
                                // the combinational logic will transition to DONE.
                                phase <= 2'd0;
                            end
                        end
                        default: phase <= 2'd0;
                    endcase
                end

                DONE: begin
                    // Sorting complete: output the sorted array and assert done
                    done <= 1;
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                end
                default: ;
            endcase
        end
    end

endmodule