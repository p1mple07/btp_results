module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    localparam IDLE  = 0;
    localparam LOAD  = 1;
    localparam SORT  = 2;
    localparam MERGE = 3;
    localparam DONE  = 4;

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

    function integer addr_width;
        addr_width = clog2(4 * N) + 1;
    endfunction

    reg [2:0]                 state;
    reg [WIDTH-1:0]           data_mem [0:N-1];
    reg [addr_width-1:0]      base_idx;
    reg [addr_width-1:0]      left_idx;
    reg [addr_width-1:0]      right_idx;
    reg [addr_width-1:0]      merge_idx;
    reg [addr_width-1:0]      subarray_size;

    reg [WIDTH-1:0]           left_val;
    reg [WIDTH-1:0]           right_val;

    integer i, k;
    integer left_end, right_end;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1'b0;
            out_data <= {N*WIDTH{1'b0}};
            base_idx <= 0;
            left_idx <= 0;
            right_idx <= 0;
            merge_idx <= 0;
            subarray_size <= 1;
        else begin
            case (state)
                IDLE: state <= LOAD;
                loadData: data_mem <= in_data;
                SORT: begin
                    if (subarray_size >= N) state <= DONE;
                    else begin
                        base_idx <= 0;
                        merge_idx <= 0;
                        left_idx <= 0;
                        right_idx <= 0;
                        state <= MERGE;
                    end
                end
                MERGE: begin
                    if (left_idx <= left_end) begin
                        if (right_idx <= right_end) begin
                            if (left_val <= right_val) begin
                                tmp_merge[merge_idx] <= left_val;
                                left_idx <= left_idx + 1;
                            else begin
                                tmp_merge[merge_idx] <= right_val;
                                right_idx <= right_idx + 1;
                            end
                            merge_idx <= merge_idx + 1;
                        end else begin
                            tmp_merge[merge_idx] <= left_val;
                            left_idx <= left_idx + 1;
                            merge_idx <= merge_idx + 1;
                        end else begin
                            tmp_merge[merge_idx] <= right_val;
                            right_idx <= right_idx + 1;
                            merge_idx <= merge_idx + 1;
                        end
                        if (merge_idx >= subarray_size * 2) begin
                            base_idx <= base_idx + subarray_size;
                            left_idx <= 0;
                            right_idx <= 0;
                            merge_idx <= 0;
                            if (base_idx + subarray_size >= N) subarray_size <= subarray_size * 2;
                        end
                    end else begin
                        tmp_merge[merge_idx] <= left_val;
                        left_idx <= 0;
                        merge_idx <= merge_idx + 1;
                    end else begin
                        tmp_merge[merge_idx] <= right_val;
                        right_idx <= 0;
                        merge_idx <= merge_idx + 1;
                    end else begin
                        for (k = 0; k < N; k = k + 1) begin
                            data_mem[base_idx + k] <= tmp_merge[k];
                        end
                        base_idx <= base_idx + subarray_size;
                        left_idx <= 0;
                        right_idx <= 0;
                        merge_idx <= 0;
                        if (base_idx + subarray_size >= N) subarray_size <= subarray_size * 2;
                    end
                end
                DONE: done <= 1'b1;
            endcase
        end
    end

    always begin
        if (state == MERGE) begin
            left_end = base_idx + subarray_size - 1;
            right_end = base_idx + (subarray_size << 1) - 1;
            left_end = min(left_end, N - 1);
            right_end = min(right_end, N - 1);
            l_addr = base_idx + left_idx;
            r_addr = base_idx + subarray_size + right_idx;
            left_val = (l_addr <= left_end) ? data_mem[l_addr] : {WIDTH{1'b1}};
            right_val = (r_addr <= right_end) ? data_mem[r_addr] : {WIDTH{1'b1}};
        else begin
            left_end = 0;
            right_end = 0;
            l_addr = 0;
            r_addr = 0;
            left_val = 0;
            right_val = 0;
        end
    end

    default: state <= IDLE;
end

endmodule