
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

    //-------------------------------------------------
    // Local Parameters & Functions
    //-------------------------------------------------
    localparam ADDR_WIDTH = clog2(4 * N) + 1;

    //-------------------------------------------------
    // Internal Signals
    //-------------------------------------------------
    reg [2:0]                 state; // Enough for 5 states: IDLE..DONE

    // Internal memory of N elements
    reg [WIDTH-1:0]           data_mem [0:N-1];

    // Indices and counters with widened bit-width
    reg [ADDR_WIDTH-1:0]      merge_idx;
    reg [ADDR_WIDTH-1:0]      subarray_size;

    // Temporary buffer for merged sub-array
    reg [WIDTH-1:0]           tmp_merge [0:N-1];

    // Temporary registers for current left/right values
    reg [WIDTH-1:0]           left_val;
    reg [WIDTH-1:0]           right_val;

    integer i, k;

    //-------------------------------------------------
    // State Machine
    //-------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset
            state         <= IDLE;
            done          <= 1'b0;
            out_data      <= {N*WIDTH{1'b0}};
            merge_idx      <= 0;
            subarray_size <= 1;
        end else begin
            case (state)

                //----------------------------------
                // IDLE: Wait for start signal
                //----------------------------------
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= LOAD;
                    end
                end

                //----------------------------------
                // LOAD: Copy from in_data to data_mem
                //----------------------------------
                LOAD: begin
                    for (i = 0; i < N; i = i + 1) begin
                        data_mem[i] <= in_data[i*WIDTH +: WIDTH];
                    end
                    subarray_size <= 1;
                    merge_idx <= 0;
                    state <= SORT;
                end

                //----------------------------------
                // SORT: Each pass merges sub-arrays of size subarray_size
                //----------------------------------
                SORT: begin
                    // If subarray_size is strictly greater than N, we've fully sorted
                    if (subarray_size >= N) begin
                        state <= DONE;
                    end else begin
                        // Prepare to merge pairs of sub-arrays
                        merge_idx <= merge_idx + 1;
                        state <= MERGE;
                    end
                end

                //----------------------------------
                // MERGE: Merge one pair of sub-arrays
                //----------------------------------
                MERGE: begin
                    // Compare/pick smaller
                    if (merge_idx < N) begin
                        if (data_mem[merge_idx*2] <= data_mem[merge_idx*2+1]) begin
                            tmp_merge[merge_idx] <= data_mem[merge_idx*2];
                        end else begin
                            tmp_merge[merge_idx] <= data_mem[merge_idx*2+1];
                        end
                        merge_idx <= merge_idx + 1;
                    end
                end

                //----------------------------------
                // DONE: Output the fully sorted array
                //----------------------------------
                DONE: begin
                    for (i = 0; i < N; i = i + 1) begin
                        out_data[i*WIDTH +: WIDTH] <= tmp_merge[i];
                    end
                    done  <= 1'b1;
                    state <= IDLE;  // or remain in DONE, your preference
                end

                default: state <= IDLE;
            endcase
        end
    end

    // Optimized merging boundaries
    always @(posedge clk or posedge rst) begin
        if (state == MERGE) begin
            // Calculate boundaries directly
            integer left_end = merge_idx * 2;
            integer right_end = merge_idx * 2 + 1;
            if (left_end >= N) left_end = N - 1;
            if (right_end >= N) right_end = N - 1;

            // Safe read for left_val
            if (merge_idx < left_end) begin
                left_val = data_mem[merge_idx*2];
            end else
                left_val = {WIDTH{1'b1}};

            // Safe read for right_val
            if (merge_idx < right_end) begin
                right_val = data_mem[merge_idx*2 + 1];
            end else
                right_val = {WIDTH{1'b1}};
        end else begin
            left_end = 0;
            right_end = 0;
            left_val = 0;
            right_val = 0;
        end
    end

endmodule
