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

    // Internal array
    reg [WIDTH-1:0] array [0:N-1];

    // FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0] state, next_state;

    // Insertion sort variables
    integer i;
    integer j;
    reg [WIDTH-1:0] key;

    // Insertion sort phases for each i
    // 0: Initialize key and j
    // 1: Shift elements greater than key
    // 2: Insert key
    reg [1:0] insert_phase;

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                // Once i reaches N, sorting is done
                if (i == N)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // FSM: main logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            done          <= 0;
            i             <= 0;
            j             <= 0;
            key           <= 0;
            insert_phase  <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Load array from in_data
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i <= 1; // Start insertion sort from index 1
                        j <= 0;
                        key <= 0;
                        insert_phase <= 0;
                    end
                end

                SORTING: begin
                    // Perform insertion sort step-by-step
                    case (insert_phase)
                        // Phase 0: Setup for inserting array[i]
                        // Note that we don't need to store key yet, so we can use a register instead of a memory.
                        0: begin
                            // Register assignment
                            key <= array[i];
                            j <= i - 1;
                            insert_phase <= 1;
                        end

                        // Phase 1: Shift elements to the right until the correct spot is found
                        1: begin
                            // Shift elements to the right until j < 0 or array[j] > key
                            if (j >= 0 && array[j] > key) begin
                                // Use shift-and- OR operation to set the leftmost bit of array[j+1] to 0
                                array[j+1] <= {array[j+1][WIDTH-2:0], 1'b0};
                                j <= j - 1;
                            } else begin
                                // We found the spot (or j < 0)
                                insert_phase <= 2;
                            end
                        end

                        // Phase 2: Insert the key at array[j+1]
                        // Here, we are using a wire assignment to store the key, then assign it to array[j+1].
                        // This way, we can avoid using a memory for storing the key.
                        2: begin
                            // Wire assignment to store the key, then assign it to array[j+1]
                            wire [WIDTH-1:0] stored_key;
                            stored_key <= key;
                            array[j+1] <= stored_key;
                            i <= i + 1;
                            insert_phase <= 0; 
                        end

                        // Default: Go back to IDLE
                        default: insert_phase <= 0;
                    endcase
                end

                DONE: begin
                    // Sorting complete, output the result
                    done <= 1;
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                end

                default: begin
                    // Should not get here
                end
            endcase
        end
    end

endmodule