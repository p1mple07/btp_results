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

    localparam ADDR_WIDTH = clog2(4 * N) + 1;

    reg [2:0]                 state;
    reg [WIDTH-1:0]           data_mem [0:N-1];
    reg [ADDR_WIDTH-1:0]      base_idx;
    reg [WIDTH-1:0]           left_val;
    reg [WIDTH-1:0]           right_val;

    integer i, k;
    integer left_idx, right_idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1'b0;
            out_data <= {N*WIDTH{1'b0}};
            base_idx <= 0;
            left_idx <= 0;
            right_idx <= 0;
        else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) state <= LOAD;
                end
                LOAD: begin
                    for (i = 0; i < N; i = i + 1) begin
                        data_mem[i] <= in_data[i*WIDTH +: WIDTH];
                    end
                    base_idx <= 0;
                    left_idx <= 0;
                    right_idx <= 0;
                    state <= SORT;
                end
                SORT: begin
                    if (subarray_size >= N) state <= DONE;
                    else state <= MERGE;
                end
                MERGE: begin
                    l_val = data_mem[left_idx];
                    r_val = data_mem[right_idx];
                    
                    if (l_val <= r_val) begin
                        tmp_merge[merge_idx] <= l_val;
                        left_idx <= left_idx + 1;
                    else begin
                        tmp_merge[merge_idx] <= r_val;
                        right_idx <= right_idx + 1;
                    end
                    merge_idx <= merge_idx + 1;
                end
                DONE: begin
                    for (i = 0; i < N; i = i + 1) begin
                        out_data[i*WIDTH +: WIDTH] <= data_mem[i];
                    end
                    done <= 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end

    always @ (*) begin
        if (state == MERGE) begin
            left_end = base_idx + subarray_size - 1;
            right_end = base_idx + (subarray_size << 1) - 1;
            left_end = min(left_end, N - 1);
            right_end = min(right_end, N - 1);
            
            l_val = data_mem[left_idx];
            r_val = data_mem[right_idx];
            
            if (left_idx <= left_end && right_idx <= right_end) begin
                if (l_val <= r_val) tmp_merge[merge_idx] <= l_val;
                else tmp_merge[merge_idx] <= r_val;
            end else if (left_idx <= left_end) tmp_merge[merge_idx] <= l_val;
            else if (right_idx <= right_end) tmp_merge[merge_idx] <= r_val;
            else for (k = 0; k < merge_idx; k++) data_mem[base_idx + k] <= tmp_merge[k];
            
            base_idx += (subarray_size << 1);
            left_idx = right_idx = merge_idx = 0;
            
            if (base_idx >= N) state <= SORT;
        end else begin
            left_end = right_end = left_idx = right_idx = merge_idx = 0;
        end
    end
end

endmodule