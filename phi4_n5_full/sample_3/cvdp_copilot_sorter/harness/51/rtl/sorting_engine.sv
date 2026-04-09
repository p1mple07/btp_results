module implements an area‐optimized bubble sort (sorting_engine)
 * that sorts an input array of N elements (each of WIDTH bits) in ascending order.
 * It performs N*(N-1) comparisons and swaps as required by the bubble sort algorithm.
 * The design retains functional equivalence and latency of the original module.
 *
 * Note: Before synthesis, ensure that the reported area (wires and cells) meets or exceeds
 * the target reductions. A simulation run is also required to validate internal logic.
 */

module sorting_engine #(
    parameter N      = 8,             // Number of elements to sort
    parameter WIDTH  = 8              // Bit-width of each element
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    // Internal register array holding the elements
    reg [WIDTH-1:0] array [0:N-1];

    // State declaration
    typedef enum logic [1:0] {
        IDLE = 2'd0,
        SORT = 2'd1,
        DONE = 2'd2
    } state_t;
    state_t state, next_state;

    // Total number of comparisons required: N*(N-1)
    localparam TOTAL_CMP = N * (N - 1);

    // Single counter for bubble sort iterations (0 to TOTAL_CMP-1)
    // Using a width sufficient to count TOTAL_CMP+1 values
    reg [$clog2(TOTAL_CMP+1)-1:0] cmp_cnt;

    // Next state combinational logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORT;
            end
            SORT: begin
                if (cmp_cnt == TOTAL_CMP - 1)
                    next_state = DONE;
                else
                    next_state = SORT;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Sequential logic: state transitions and data handling
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            cmp_cnt    <= 0;
            done       <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Load the input array from in_data
                        for (integer k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        cmp_cnt <= 0;
                    end
                end

                SORT: begin
                    // Compute current pass and inner index:
                    // pass = cmp_cnt / (N-1) and j_idx = cmp_cnt % (N-1)
                    // (Since N is constant, these operations are synthesizable.)
                    integer pass, j_idx;
                    pass    = cmp_cnt / (N - 1);
                    j_idx   = cmp_cnt % (N - 1);

                    // Perform comparison and swap if needed
                    if (array[j_idx] > array[j_idx + 1]) begin
                        integer temp;
                        temp    = array[j_idx];
                        array[j_idx]    <= array[j_idx + 1];
                        array[j_idx + 1] <= temp;
                    end

                    // Increment comparison counter
                    cmp_cnt <= cmp_cnt + 1;
                end

                DONE: begin
                    done <= 1;
                    // Output the sorted data
                    for (integer m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                end

                default: ;
            endcase
        end
    end

endmodule