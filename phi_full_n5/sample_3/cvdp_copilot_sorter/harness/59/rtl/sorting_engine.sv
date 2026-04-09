module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [N*WIDTH-1:0] in_data,
    output reg done,
    output reg [N*WIDTH-1:0] out_data
);

    // Internal array
    reg [WIDTH-1:0] array [0:N-1];

    // FSM states
    localparam IDLE = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state, next_state;

    // Insertion sort variables
    integer i;
    integer j;
    reg [WIDTH-1:0] key;

    // Optimized FSM: Next state logic
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

    // Optimized FSM: main logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            done          <= 0;
            i             <= 0;
            j             <= 0;
            key           <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    // Initialization in one step
                    key <= array[0];
                    j <= 0;
                    i <= 1;
                    insert_phase <= 0;
                end

                SORTING: begin
                    // Perform insertion sort step-by-step
                    case (insert_phase)
                        0: begin
                            if (i < N) begin
                                key <= array[i];
                                j <= i - 1;
                                insert_phase <= 1;
                            end
                            else begin
                                // Reached end, set key to 0 to exit
                                key <= 0;
                                insert_phase <= 2;
                            end
                        end

                        1: begin
                            // Shift elements to the right until the correct spot is found
                            if (j >= 0 && array[j] > key) begin
                                array[j+1] <= array[j];
                                j <= j - 1;
                            end else begin
                                // Found the spot, no more shifting needed
                                insert_phase <= 2;
                            end
                        end

                        2: begin
                            // Insert the key at array[j+1]
                            array[j+1] <= key;
                            i <= i + 1;
                            insert_phase <= 0;
                        end

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
