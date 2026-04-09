module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 32
)(
    input wire w_clk,
    input wire w_rst,
    input wire w_inc,
    input wire w_data,
    input r_clk,
    input wire r_rst,
    input wire r_inc,
    output reg w_full,
    output reg r_empty,
    output reg [DATA_WIDTH-1:0] r_data,
    output reg [DATA_WIDTH-1:0] w_full_reg,
    output reg [DATA_WIDTH-1:0] r_empty_reg
);

    // Synchronize signals across clock domains
    always @(posedge w_clk or negedge w_rst) begin
        if (w_rst) begin
            w_full <= 1'b0;
            r_empty <= 1'b1;
            w_full_reg <= 1'b0;
            r_empty_reg <= 1'b1;
        end else begin
            // ...
        end
    end

    // Declare internal signals
    reg [DATA_WIDTH-1:0] data;
    reg wr_pos, rd_pos;
    reg [1:0] wr_gray, rd_gray;

    // Initialize counters
    initial begin
        wr_pos = 32'd0;
        rd_pos = 32'd0;
    end

    // Write process
    always @(posedge w_clk or negedge w_rst) begin
        if (w_rst) begin
            wr_pos <= 32'd0;
            rd_pos <= 32'd0;
            w_full_reg <= 1'b0;
            r_empty_reg <= 1'b1;
        end else begin
            if (w_inc) begin
                // Check if FIFO is full
                if (wr_pos == rd_pos) begin
                    w_full_reg <= 1'b1;
                end else if (wr_pos == rd_pos + 1) begin
                    // overflow? but we don't need that
                end else if (wr_pos == rd_pos - 1) begin
                    // underflow? not needed
                end else begin
                    // just shift
                    data <= data >> 1;
                    wr_pos <= wr_pos + 1;
                    rd_pos <= rd_pos + 1;
                end
            end
            if (w_data) begin
                data <= w_data;
            end
        end
    end

    // Read process
    always @(posedge r_clk or negedge r_rst) begin
        if (r_rst) begin
            rd_pos <= 32'd0;
            w_full_reg <= 1'b0;
            r_empty_reg <= 1'b1;
        end else begin
            if (r_inc) begin
                if (rd_pos == wr_pos) begin
                    r_empty_reg <= 1'b0;
                end else if (rd_pos == wr_pos + 1) begin
                    // underflow?
                end else if (rd_pos == wr_pos - 1) begin
                    // overflow?
                end else begin
                    data <= data << 1;
                    rd_pos <= rd_pos - 1;
                    w_full_reg <= 1'b0;
                end
            end
            if (r_data) begin
                r_data <= data;
            end
        end
    end

    // Outputs
    assign w_full = w_full_reg;
    assign r_empty = r_empty_reg;
    assign r_data = data;
    assign w_full_reg = w_full;
    assign r_empty_reg = r_empty;

endmodule
