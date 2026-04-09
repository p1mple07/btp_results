module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 8
)(
    input w_clk,
    input w_rst,
    input push,
    input r_rst,
    input r_clk,
    input pop,
    input [DATA_WIDTH-1:0] w_data,
    output reg [DATA_WIDTH-1:0] r_data,
    output reg r_empty,
    output reg w_full
);

    // Internal signals
    logic [DATA_WIDTH-1:0] mem[DEPTH];
    logic [DATA_WIDTH-1:0] w_ptr, r_ptr;
    logic wq1_rptr, wq2_rptr, rq1_wptr, rq2_wptr;

    // Converters
    function automatic logic [DATA_WIDTH-1:0] gray2bin(logic [DATA_WIDTH-1:0] x);
        logic [DATA_WIDTH-1:0] bin = x ^ ((x >> 1) & 1'b1);
        return bin;
    endfunction

    function automatic logic [DATA_WIDTH-1:0] bin2gray(logic [DATA_WIDTH-1:0] x);
        logic [DATA_WIDTH-1:0] gray = x ^ (x >> 1);
        return gray;
    endfunction

    // Initialize pointers
    initial begin
        w_ptr = 0;
        r_ptr = 0;
        wq1_rptr = 1'bz;
        wq2_rptr = 1'bz;
        rq1_wptr = 1'bz;
        rq2_wptr = 1'bz;
    end

    // Push operation
    task async_push;
        async always @(posedge w_clk or negedge w_rst) begin
            if (w_rst) begin
                w_ptr <= 0;
                wq1_rptr <= 1'bz;
                wq2_rptr <= 1'bz;
                rq1_wptr <= 1'bz;
                rq2_wptr <= 1'bz;
            end else begin
                if (!full) begin
                    mem[w_ptr] <= w_data;
                    w_ptr = w_ptr + 1;
                    wq1_rptr <= w_ptr;
                end
            end
        end
    endtask

    // Pop operation
    task async_pop;
        async always @(posedge r_clk or negedge r_rst) begin
            if (r_rst) begin
                r_ptr <= 0;
                rq1_wptr <= 1'bz;
                rq2_wptr <= 1'bz;
                wq1_rptr <= 1'bz;
                wq2_rptr <= 1'bz;
            end else begin
                if (!empty) begin
                    r_data <= pushed_data[r_ptr];
                    r_ptr = r_ptr - 1;
                    wr_ptr_to_rq2_wptr <= rq2_wptr;
                end
            end
        end
    endtask

    // Main module instantiation
    async_filo_inst async_filo_inst (
        .w_clk(w_clk),
        .w_rst(w_rst),
        .push(push),
        .r_rst(r_rst),
        .r_clk(r_clk),
        .pop(pop),
        .w_data(w_data),
        .r_data(r_data),
        .r_empty(r_empty),
        .w_full(w_full)
    );

endmodule
