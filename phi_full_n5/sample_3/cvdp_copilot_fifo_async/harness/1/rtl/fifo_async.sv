module fifo_async #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
) (
    input wire w_clk,
    input wire w_rst,
    input wire w_inc,
    input wire [DATA_WIDTH-1:0] w_data,
    input wire r_clk,
    input wire r_rst,
    input wire r_inc,
    output reg w_full,
    output reg r_empty,
    output reg [DATA_WIDTH-1:0] r_data
);

    // Write pointer
    reg [DATA_WIDTH-1:0] w_ptr_sync;
    reg [DATA_WIDTH-1:0] w_ptr_sync_next;

    // Read pointer
    reg [DATA_WIDTH-1:0] r_ptr_sync;
    reg [DATA_WIDTH-1:0] r_ptr_sync_next;

    // Cross-clock synchronizers
    always @(posedge w_clk) begin
        w_ptr_sync <= r_ptr_sync;
        r_ptr_sync <= w_ptr_sync;
    end

    always @(posedge r_clk) begin
        r_ptr_sync_next <= r_ptr_sync;
        r_ptr_sync <= w_ptr_sync_next;
    end

    // Gray counter for write pointer
    always @(posedge w_clk) begin
        if (w_inc) begin
            w_ptr_sync_next = w_ptr_sync ^ (1 << DATA_WIDTH-1);
        end
        w_ptr_sync <= w_ptr_sync_next;
    end

    // Gray counter for read pointer
    always @(posedge r_clk) begin
        if (r_inc) begin
            r_ptr_sync_next = r_ptr_sync ^ (1 << DATA_WIDTH-1);
        end
        r_ptr_sync <= r_ptr_sync_next;
    end

    // FIFO logic
    integer i;
    always @(posedge w_clk or posedge r_clk) begin
        if (w_rst) begin
            w_ptr_sync <= (DATA_WIDTH-1);
            r_ptr_sync <= (DATA_WIDTH-1);
        end

        if (w_inc) begin
            if (w_ptr_sync == DEPTH - 1) begin
                w_full <= 1;
                w_ptr_sync <= 0;
            end else begin
                w_ptr_sync <= w_ptr_sync + 1;
            end
        end

        if (r_rst) begin
            r_ptr_sync <= (DATA_WIDTH-1);
        end

        if (r_inc) begin
            if (r_ptr_sync == 0) begin
                r_empty <= 1;
                r_ptr_sync <= DEPTH - 1;
            end else begin
                r_ptr_sync <= r_ptr_sync - 1;
            end
        end

        if (w_ptr_sync == r_ptr_sync) begin
            r_empty <= 1;
        end

        if (w_ptr_sync == (DEPTH - 1) && r_ptr_sync == (DEPTH - 1)) begin
            w_full <= 1;
        end

        if (w_ptr_sync == DEPTH - 1 && r_ptr_sync <= w_ptr_sync) begin
            r_data <= {w_data, {DATA_WIDTH-1{1'b0}}};
            r_empty <= 0;
        end
    end
endmodule
