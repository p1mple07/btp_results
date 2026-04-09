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
                        // (same as before)
                        0: begin
                            if (i < N) begin
                                key <= array[i];
                                j <= i - 1;
                                insert_phase <= 1;
                            end
                            // If i == N, sorting complete, next cycle moves to DONE
                        end

                        // Phase 1: Shift elements to the right until the correct spot is found
                        // (same as before)
                        1: begin
                            if (j >= 0 && array[j] > key) begin
                                array[j+1] <= array[j];
                                j <= j - 1;
                            end else begin
                                // We found the spot (or j < 0)
                                insert_phase <= 2;
                            end
                        end

                        // Phase 2: Insert the key at array[j+1]
                        // (same as before)
                        2: begin
                            array[j+1] <= key;
                            i <= i + 1;
                            insert_phase <= 0; 
                        end

                        // Other cases
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