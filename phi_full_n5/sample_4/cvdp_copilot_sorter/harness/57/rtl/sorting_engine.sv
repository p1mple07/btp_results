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

    // Local Parameters & Functions
    localparam IDLE  = 0;
    localparam LOAD  = 1;
    localparam SORT  = 2;
    localparam MERGE = 3;
    localparam DONE  = 4;

    // Calculate ADDR_WIDTH
    localparam ADDR_WIDTH = clog2(4 * N) + 1;

    // Internal Signals
    reg [WIDTH-1:0]           data_mem [0:N-1];
    reg [ADDR_WIDTH-1:0]      base_idx;
    reg [ADDR_WIDTH-1:0]      left_idx;
    reg [ADDR_WIDTH-1:0]      right_idx;
    reg [ADDR_WIDTH-1:0]      merge_idx;
    reg [ADDR_WIDTH-1:0]      subarray_size;

    // Temporary buffers
    reg [WIDTH-1:0]           tmp_merge [0:N-1];

    // Merge Logic Optimization
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset
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

                // ... [Rest of the state machine remains the same]

                MERGE: begin
                    // Perform merging with loop unrolling
                    for (int i = 0; i < subarray_size; i = i + 2) begin
                        if (left_idx[i] < right_idx[i]) begin
                            tmp_merge[merge_idx + i] <= left_val[i];
                            left_idx[i] <= left_idx[i] + 1;
                        end else begin
                            tmp_merge[merge_idx + i] <= right_val[i];
                            right_idx[i] <= right_idx[i] + 1;
                        end
                    end

                    // Handle odd subarray_size
                    if (subarray_size % 2 != 0) begin
                        if (left_idx[subarray_size - 1] < right_idx[subarray_size - 1]) begin
                            tmp_merge[merge_idx + subarray_size - 1] <= left_val[subarray_size - 1];
                            left_idx[subarray_size - 1] <= left_idx[subarray_size - 1] + 1;
                        end else begin
                            tmp_merge[merge_idx + subarray_size - 1] <= right_val[subarray_size - 1];
                            right_idx[subarray_size - 1] <= right_idx[subarray_size - 1] + 1;
                        end
                    end

                    // Move base_idx and merge_idx
                    base_idx  <= base_idx + (subarray_size << 1);
                    left_idx  <= 0;
                    right_idx <= 0;
                    merge_idx <= 0;

                    // Check if merge_idx is at the end
                    if (merge_idx + (subarray_size << 1) >= N) begin
                        subarray_size <= subarray_size << 1;
                        state <= SORT;
                    end
                end

                // ... [Rest of the state machine remains the same]
            endcase
        end
    end

    // Merge Logic for Indices
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset indices
            left_end  = 0;
            right_end = 0;
            left_val = 0;
            right_val = 0;
        end else begin
            // Unroll merge logic
            for (int i = 0; i < subarray_size; i += 2) begin
                if (left_idx[i] < right_idx[i]) begin
                    left_end  = left_idx[i] + subarray_size - 1;
                    right_end = right_idx[i] + subarray_size - 1;
                    left_val  = data_mem[left_idx[i]];
                    right_val = data_mem[right_idx[i]];
                end else if (i < subarray_size - 1) begin
                    left_end  = left_idx[i] + subarray_size - 1;
                    right_end = right_idx[i] + subarray_size - 1;
                    left_val  = data_mem[left_idx[i + 1]];
                    right_val = data_mem[right_idx[i + 1]];
                end
            end
        end
    end

endmodule
