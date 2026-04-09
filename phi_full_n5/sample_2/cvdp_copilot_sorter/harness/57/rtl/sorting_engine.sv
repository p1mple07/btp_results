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

    // Local Parameters & Functions
    // (unchanged)

    // Internal Signals
    // (unchanged)

    // State Machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset
            state <= IDLE;
            done <= 1'b0;
            out_data <= {N*WIDTH{1'b0}};
            base_idx  <= 0;
            left_idx  <= 0;
            right_idx <= 0;
            merge_idx <= 0;
            subarray_size <= 1;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    for (i = 0; i < N; i = i + 1) begin
                        data_mem[i] <= in_data[i*WIDTH +: WIDTH];
                    end
                    base_idx  <= 0;
                    left_idx  <= 0;
                    right_idx <= 0;
                    merge_idx <= 0;
                    subarray_size <= 1;

                    state <= SORT;
                end

                SORT: begin
                    if (subarray_size >= N) begin
                        state <= DONE;
                    end else begin
                        state <= MERGE;
                    end
                end

                MERGE: begin
                    // Unroll comparison loop
                    for (k = 0; k < subarray_size; k = k + 1) begin
                        if (left_val <= right_val) begin
                            tmp_merge[merge_idx] <= left_val;
                            left_idx <= left_idx + 1;
                            merge_idx <= merge_idx + 1;
                        end else begin
                            tmp_merge[merge_idx] <= right_val;
                            right_idx <= right_idx + 1;
                            merge_idx <= merge_idx + 1;
                        end
                    end

                    // Move base_idx to next pair of sub-arrays
                    base_idx  <= base_idx + (subarray_size << 1);
                    left_idx  <= 0;
                    right_idx <= 0;
                    merge_idx <= 0;

                    if ((base_idx + (subarray_size << 1)) >= N) begin
                        subarray_size <= subarray_size << 1;
                        state         <= SORT;
                    end
                end

                DONE: begin
                    for (i = 0; i < N; i = i + 1) begin
                        out_data[i*WIDTH +: WIDTH] <= data_mem[i];
                    end
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    always @(*) begin
        // Calculate base_idx, left_end, right_end, l_addr, r_addr, left_val, right_val
        // (unchanged)
    end

endmodule
