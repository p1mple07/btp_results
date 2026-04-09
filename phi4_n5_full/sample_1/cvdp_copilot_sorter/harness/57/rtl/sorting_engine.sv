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
    localparam IDLE  = 0;
    localparam LOAD  = 1;
    localparam SORT  = 2;
    localparam MERGE = 3;

    // Function to compute floor(log2(value)) at compile time
    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = 1; i < value; i = i << 1)
                clog2 = clog2 + 1;
        end
    endfunction

    // ADDR_WIDTH is chosen to be large enough for subarray_size
    localparam ADDR_WIDTH = clog2(4 * N) + 1;

    //-------------------------------------------------
    // Internal Signals
    //-------------------------------------------------
    reg [2:0] state; // States: IDLE, LOAD, SORT, MERGE

    // Internal memory for N elements
    reg [WIDTH-1:0] data_mem [0:N-1];

    // Indices and counters (widened bit-width)
    reg [ADDR_WIDTH-1:0] base_idx;
    reg [ADDR_WIDTH-1:0] left_idx;
    reg [ADDR_WIDTH-1:0] right_idx;
    reg [ADDR_WIDTH-1:0] merge_idx;
    reg [ADDR_WIDTH-1:0] subarray_size;

    // Temporary buffer for merged sub-array
    reg [WIDTH-1:0] tmp_merge [0:N-1];

    integer i, k;

    //-------------------------------------------------
    // State Machine
    //-------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            done          <= 1'b0;
            out_data      <= {N*WIDTH{1'b0}};
            base_idx      <= 0;
            left_idx      <= 0;
            right_idx     <= 0;
            merge_idx     <= 0;
            subarray_size <= 1;
        end else begin
            case (state)
                // IDLE: Wait for start signal
                IDLE: begin
                    done <= 1'b0;
                    if (start)
                        state <= LOAD;
                end

                // LOAD: Copy input data into internal memory
                LOAD: begin
                    for (i = 0; i < N; i = i + 1)
                        data_mem[i] <= in_data[i*WIDTH +: WIDTH];
                    base_idx      <= 0;
                    left_idx      <= 0;
                    right_idx     <= 0;
                    merge_idx     <= 0;
                    subarray_size <= 1;
                    state         <= SORT;
                end

                // SORT: Check if fully sorted; if so, output data immediately (latency optimized)
                SORT: begin
                    if (subarray_size >= N) begin
                        // Output sorted data immediately (reduces latency by 1 cycle)
                        for (i = 0; i < N; i = i + 1)
                            out_data[i*WIDTH +: WIDTH] <= data_mem[i];
                        done <= 1'b1;
                        state <= IDLE;
                    end else begin
                        // Prepare for a merge pass
                        base_idx  <= 0;
                        merge_idx <= 0;
                        left_idx  <= 0;
                        right_idx <= 0;
                        state     <= MERGE;
                    end
                end

                // MERGE: Merge one pair of sub-arrays
                MERGE: begin
                    // Declare local variables to compute boundaries and values
                    reg [WIDTH-1:0] lv, rv;
                    integer le, re, la, ra;
                    
                    // Compute boundaries for left and right sub-arrays
                    le = base_idx + subarray_size - 1;
                    re = base_idx + (subarray_size << 1) - 1;
                    if (le >= N)
                        le = N - 1;
                    if (re >= N)
                        re = N - 1;
                    la = base_idx + left_idx;
                    ra = base_idx + subarray_size + right_idx;
                    
                    // Safe read for left value
                    if ((la <= le) && (la < N))
                        lv = data_mem[la];
                    else
                        lv = {WIDTH{1'b1}};
                    
                    // Safe read for right value
                    if ((ra <= re) && (ra < N))
                        rv = data_mem[ra];
                    else
                        rv = {WIDTH{1'b1}};
                    
                    if ((la <= le) && (ra <= re)) begin
                        if (lv <= rv) begin
                            tmp_merge[merge_idx] <= lv;
                            left_idx <= left_idx + 1;
                        end else begin
                            tmp_merge[merge_idx] <= rv;
                            right_idx <= right_idx + 1;
                        end
                        merge_idx <= merge_idx + 1;
                    end else if (la <= le) begin
                        tmp_merge[merge_idx] <= lv;
                        left_idx <= left_idx + 1;
                        merge_idx <= merge_idx + 1;
                    end else if (ra <= re) begin
                        tmp_merge[merge_idx] <= rv;
                        right_idx <= right_idx + 1;
                        merge_idx <= merge_idx + 1;
                    end else begin
                        // Both sub-arrays are exhausted: write back merged results
                        for (k = 0; k < N; k = k + 1) begin
                            if ((k < merge_idx) && (k < (subarray_size << 1)) && ((base_idx + k) < N))
                                data_mem[base_idx + k] <= tmp_merge[k];
                        end
                        // Move to next pair of sub-arrays
                        base_idx  <= base_idx + (subarray_size << 1);
                        left_idx  <= 0;
                        right_idx <= 0;
                        merge_idx <= 0;
                        // If all pairs in this pass are merged, double subarray_size and go back to SORT
                        if ((base_idx + (subarray_size << 1)) >= N) begin
                            subarray_size <= subarray_size << 1;
                            state         <= SORT;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule