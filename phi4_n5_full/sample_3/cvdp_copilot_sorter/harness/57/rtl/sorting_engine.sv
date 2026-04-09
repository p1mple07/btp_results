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
            for (i = 1; i < value; i = i << 1) begin
                clog2 = clog2 + 1;
            end
        end
    endfunction

    // ADDR_WIDTH is chosen to store up to ~4*N elements safely.
    localparam ADDR_WIDTH = clog2(4 * N) + 1;

    //-------------------------------------------------
    // Internal Signals
    //-------------------------------------------------
    reg [2:0]                 state; // States: IDLE, LOAD, SORT, MERGE

    // Internal memory of N elements
    reg [WIDTH-1:0]           data_mem [0:N-1];

    // Indices and counters with widened bit-width
    reg [ADDR_WIDTH-1:0]      base_idx;
    reg [ADDR_WIDTH-1:0]      left_idx;
    reg [ADDR_WIDTH-1:0]      right_idx;
    reg [ADDR_WIDTH-1:0]      merge_idx;
    reg [ADDR_WIDTH-1:0]      subarray_size;

    // Temporary buffer for merged sub-array
    reg [WIDTH-1:0]           tmp_merge [0:N-1];

    // Temporary registers for current left/right values (computed on‐the‐fly)
    reg [WIDTH-1:0]           left_val;
    reg [WIDTH-1:0]           right_val;

    integer i, k;

    //-------------------------------------------------
    // Optimized State Machine (Sequential and Combinational Logic Combined)
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
        end
        else begin
            case (state)
                //----------------------------------
                // IDLE: Wait for start signal
                //----------------------------------
                IDLE: begin
                    done <= 1'b0;
                    if (start)
                        state <= LOAD;
                end

                //----------------------------------
                // LOAD: Copy from in_data to data_mem
                //----------------------------------
                LOAD: begin
                    for (i = 0; i < N; i = i + 1) begin
                        data_mem[i] <= in_data[i*WIDTH +: WIDTH];
                    end

                    // Initialize indices for sorting
                    base_idx      <= 0;
                    left_idx      <= 0;
                    right_idx     <= 0;
                    merge_idx     <= 0;
                    subarray_size <= 1;

                    state <= SORT;
                end

                //----------------------------------
                // SORT: Prepare for merge pass; if final pass, go directly to MERGE
                //----------------------------------
                SORT: begin
                    // Always transition to MERGE (final pass when subarray_size==N)
                    state <= MERGE;
                end

                //----------------------------------
                // MERGE: Merge one pair of sub-arrays and, if complete, output sorted array.
                //         This state now incorporates the final output logic formerly in DONE.
                //----------------------------------
                MERGE: begin
                    // Compute boundaries and addresses (combinational logic integrated here)
                    integer local_left_end, local_right_end, local_l_addr, local_r_addr;
                    reg [WIDTH-1:0] local_left_val, local_right_val;
                    
                    local_left_end = base_idx + subarray_size - 1;
                    local_right_end = base_idx + (subarray_size << 1) - 1;
                    if (local_left_end  >= N)
                        local_left_end  = N - 1;
                    if (local_right_end >= N)
                        local_right_end = N - 1;
                    
                    local_l_addr = base_idx + left_idx;
                    local_r_addr = base_idx + subarray_size + right_idx;
                    
                    if ((local_l_addr <= local_left_end) && (local_l_addr < N))
                        local_left_val = data_mem[local_l_addr];
                    else
                        local_left_val = {WIDTH{1'b1}};
                    
                    if ((local_r_addr <= local_right_end) && (local_r_addr < N))
                        local_right_val = data_mem[local_r_addr];
                    else
                        local_right_val = {WIDTH{1'b1}};

                    // Merge step: compare and select the smaller element
                    if ((local_l_addr <= local_left_end) && (local_r_addr <= local_right_end)) begin
                        if (local_left_val <= local_right_val) begin
                            tmp_merge[merge_idx] <= local_left_val;
                            left_idx <= left_idx + 1;
                        end
                        else begin
                            tmp_merge[merge_idx] <= local_right_val;
                            right_idx <= right_idx + 1;
                        end
                        merge_idx <= merge_idx + 1;
                    end
                    else if (local_l_addr <= local_left_end) begin
                        tmp_merge[merge_idx] <= local_left_val;
                        left_idx <= left_idx + 1;
                        merge_idx <= merge_idx + 1;
                    end
                    else if (local_r_addr <= local_right_end) begin
                        tmp_merge[merge_idx] <= local_right_val;
                        right_idx <= right_idx + 1;
                        merge_idx <= merge_idx + 1;
                    end
                    else begin
                        // Both sub-arrays are exhausted; write back merged results
                        for (k = 0; k < N; k = k + 1) begin
                            if ((k < merge_idx) && (k < (subarray_size << 1)) && ((base_idx + k) < N))
                                data_mem[base_idx + k] <= tmp_merge[k];
                        end

                        // Update indices for next merge pair
                        base_idx  <= base_idx + (subarray_size << 1);
                        left_idx  <= 0;
                        right_idx <= 0;
                        merge_idx <= 0;

                        // If merging complete (final pass), output sorted array and mark done.
                        if ((base_idx + (subarray_size << 1)) >= N) begin
                            for (i = 0; i < N; i = i + 1) begin
                                out_data[i*WIDTH +: WIDTH] <= data_mem[i];
                            end
                            done  <= 1'b1;
                            state <= IDLE;
                        end
                        else begin
                            // Not final pass: double subarray_size and prepare for next merge pass.
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