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
    reg [ADDR_WIDTH-1:0]      left_idx;
    reg [ADDR_WIDTH-1:0]      right_idx;
    reg [ADDR_WIDTH-1:0]      merge_idx;
    reg [ADDR_WIDTH-1:0]      subarray_size;
    reg [WIDTH-1:0]           tmp_merge [0:N-1];
    reg [WIDTH-1:0]           left_val;
    reg [WIDTH-1:0]           right_val;
    integer i, k;

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
                    base_idx      <= 0;
                    left_idx      <= 0;
                    right_idx     <= 0;
                    merge_idx     <= 0;
                    subarray_size <= 1;
                    state <= SORT;
                end

                SORT: begin
                    if (subarray_size > N) begin
                        state <= DONE;
                    end else begin
                        base_idx  <= 0;
                        merge_idx <= 0;
                        left_idx  <= 0;
                        right_idx <= 0;
                        state     <= MERGE;
                    end
                end

                MERGE: begin
                    integer left_end, right_end;
                    integer l_addr,    r_addr;

                    left_end  = base_idx + subarray_size - 1;
                    if (left_end >= N) left_end = N - 1;

                    right_end = base_idx + (subarray_size << 1) - 1;
                    if (right_end >= N) right_end = N - 1;

                    l_addr = base_idx + left_idx;
                    r_addr = base_idx + subarray_size + right_idx;

                    if ((l_addr <= left_end) && (l_addr < N)) 
                        left_val = data_mem[l_addr];
                    else 
                        left_val = {WIDTH{1'b1}};

                    if ((r_addr <= right_end) && (r_addr < N)) 
                        right_val = data_mem[r_addr];
                    else 
                        right_val = {WIDTH{1'b1}};

                    if ((l_addr <= left_end) && (r_addr <= right_end)) begin
                        if (left_val <= right_val) begin
                            tmp_merge[merge_idx] <= left_val;
                            left_idx <= left_idx + 1;
                        end else begin
                            tmp_merge[merge_idx] <= right_val;
                            right_idx <= right_idx + 1;
                        end
                        merge_idx <= merge_idx + 1;
                    end
                    else if (l_addr <= left_end) begin
                        tmp_merge[merge_idx] <= left_val;
                        left_idx <= left_idx + 1;
                        merge_idx <= merge_idx + 1;
                    end
                    else if (r_addr <= right_end) begin
                        tmp_merge[merge_idx] <= right_val;
                        right_idx <= right_idx + 1;
                        merge_idx <= merge_idx + 1;
                    end
                    else begin
                        for (k = 0; k < N; k = k + 1) begin
                            if ( (k < merge_idx) &&
                                 (k < (subarray_size << 1)) &&
                                 ((base_idx + k) < N) )
                            begin
                                data_mem[base_idx + k] <= tmp_merge[k];
                            end
                        end
                        base_idx  <= base_idx + (subarray_size << 1);
                        left_idx  <= 0;
                        right_idx <= 0;
                        merge_idx <= 0;

                        if ((base_idx + (subarray_size << 1)) >= N) begin
                            subarray_size <= subarray_size << 1;
                            state         <= SORT;
                        end
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

endmodule