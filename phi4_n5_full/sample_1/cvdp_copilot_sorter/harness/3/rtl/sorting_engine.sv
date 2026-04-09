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

    // FSM state register
    reg [1:0] state;

    // Registers for insertion sort indices
    // i: index of the element to be inserted (starting from 1)
    // j: inner loop index used for shifting elements (starting from i-1)
    reg [$clog2(N)-1:0] i;
    reg [$clog2(N)-1:0] j;

    // Temporary register to hold the key element being inserted
    reg [WIDTH-1:0] key;

    // Step counter for insertion sort sub-steps
    // (Assuming 8 bits is sufficient for the step count)
    reg [7:0] step;

    // FSM: Sequential always block implementing the insertion sort algorithm
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            i       <= 0;
            j       <= 0;
            done    <= 0;
            step    <= 0;
            key     <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Load the array from in_data
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        // Start insertion sort from the second element (first element is already sorted)
                        i <= 1;
                        j <= i - 1;  // j = 0
                        state <= SORTING;
                        done <= 0;
                    end
                end

                SORTING: begin
                    // Use a case statement on 'step' to implement the insertion sort steps.
                    case (step)
                        0: begin
                            // Step 0: Read the key element from array[i]
                            key <= array[i];
                            step <= 1;
                        end

                        1: begin
                            // Step 1: Check if shifting is needed.
                            // For j==0, compare with the first element.
                            if (j == 0) begin
                                if (array[0] > key) begin
                                    // Shift array[0] to array[1]
                                    array[1] <= array[0];
                                end
                                step <= 2;  // Proceed to insertion step
                            end else begin
                                if (array[j] > key) begin
                                    // Shift array[j] to array[j+1] and decrement j
                                    array[j+1] <= array[j];
                                    j <= j - 1;
                                    step <= 1;  // Re-check condition after shifting
                                end else begin
                                    step <= 2;  // Correct position found; proceed to insertion
                                end
                            end
                        end

                        2: begin
                            // Step 2: Insert the key element into its correct position
                            array[j+1] <= key;
                            if (i < N-1) begin
                                // Prepare for the next element
                                i <= i + 1;
                                j <= i - 1;  // Set j to i-1 for the next iteration
                                step <= 0;  // Restart the steps for the next element
                            end else begin
                                // All elements have been processed; move to completion step
                                step <= 3;
                            end
                        end

                        3: begin
                            // Step 3: Transition to DONE state
                            state <= DONE;
                        end
                    endcase
                end

                DONE: begin
                    // Output the sorted array and assert the done signal
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                    done <= 1;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule