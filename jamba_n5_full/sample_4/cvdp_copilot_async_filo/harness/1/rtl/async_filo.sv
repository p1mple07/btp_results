module async_filo (
    input         w_clk,
    input         w_rst,
    input         push,
    input         r_rst,
    input         r_clk,
    input         pop,
    input        [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data,
    output logic  r_empty,
    output logic  w_full
);

    localparam DATA_WIDTH = 16, DEPTH = 8;
    logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
    logic [$clog2(DEPTH):0] w_ptr, r_ptr;
    logic [$clog2(DEPTH):0] wq2_rptr, rq2_wptr;
    logic [DATA_WIDTH-1:0] w_data_in;
    logic [DATA_WIDTH-1:0] w_data_out;
    logic [DATA_WIDTH-1:0] r_data_out;
    logic r_empty_flag;
    logic w_full_flag;

    initial begin
        w_ptr <= 0;
        r_ptr <= 0;
        w_full_flag <= 0;
        r_empty_flag <= 1;
    end

    always_ff @(posedge w_clk, posedge w_rst) begin
        if (w_rst) begin
            w_ptr <= 0;
            r_ptr <= 0;
            w_full_flag <= 0;
            r_empty_flag <= 1;
        end else begin
            if (push) begin
                if (!full) begin
                    w_ptr <= w_ptr + 1;
                    mem[w_ptr] <= w_data;
                end
            end
        end
    end

    always_ff @(posedge r_clk, posedge r_rst) begin
        if (r_rst) begin
            r_count_bin <= 0;
            r_ptr <= 0;
        end else begin
            if (pop) begin
                if (!empty) begin
                    r_data_out <= mem[r_ptr];
                    r_ptr <= r_ptr - 1;
                end
            end
        end
    end

    always_ff @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            r_empty_flag <= 1;
        end else begin
            r_empty_flag <= w_ptr == r_ptr;
        end
    end

    always_ff @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            w_full_flag <= 0;
        end else begin
            w_full_flag <= w_ptr == DEPTH - 1;
        end
    end

    assign wq2_rptr = w_ptr;
    assign rq2_wptr = r_ptr;

    assign w_full = w_full_flag;
    assign r_empty = r_empty_flag;

    assign r_data = r_data_out;
    assign r_empty = r_empty_flag;
    assign w_full = w_full_flag;

endmodule
