module rtl_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 32
)(
    input w_clk,
    input w_rst,
    input w_inc,
    input w_data,
    input r_clk,
    input r_rst,
    input r_inc,
    output reg w_full,
    output reg r_empty,
    output reg [DATA_WIDTH-1:0] r_data,
    output reg [DATA_WIDTH-1:0] w_data
);

    localparam NUM_CYCLE_CYCLES = 2;
    reg [NUM_CYCLE_CYCLES-1:0] w_cycle_count;
    reg [NUM_CYCLE_CYCLES-1:0] r_cycle_count;

    always @(posedge w_clk or negedge w_rst) begin
        if (!w_rst) begin
            w_ptr <= {DATA_WIDTH{1'b0}};
            w_cycle_count <= {NUM_CYCLE_CYCLES{1'b0}};
        end else begin
            if (w_inc) begin
                w_ptr <= {w_ptr[DATA_WIDTH-1:0], 1'b1};
                w_cycle_count <= w_cycle_count ^ 4'b1000;
            end
        end
    end

    always @(posedge r_clk or negedge r_rst) begin
        if (!r_rst) begin
            r_ptr <= {DATA_WIDTH{1'b0}};
            r_cycle_count <= {NUM_CYCLE_CYCLES{1'b0}};
        end else begin
            if (r_inc) begin
                r_ptr <= {r_ptr[DATA_WIDTH-1:0], 1'b1};
                r_cycle_count <= r_cycle_count ^ 4'b1000;
            end
        end
    end

    always @(posedge w_clk or negedge r_clk) begin
        if (w_ptr == r_ptr && w_ptr[DATA_WIDTH-1] == r_ptr[DATA_WIDTH-1]) begin
            w_full = 1'b1;
            w_ptr <= {DATA_WIDTH{1'b1}};
        end else if (w_ptr[DATA_WIDTH-1] != r_ptr[DATA_WIDTH-1]) && (w_ptr[DATA_WIDTH-2] == r_ptr[DATA_WIDTH-2]) && (w_ptr[DATA_WIDTH-3] == r_ptr[DATA_WIDTH-3]) && ...
        // Actually we can just check if they match completely.
        assign w_full = (w_ptr == r_ptr) ? 1'b1 : 1'b0;

        assign r_empty = (r_ptr == {DATA_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

        assign r_data = if (r_ptr == {DATA_WIDTH{1'b0}}) r_ptr[DATA_WIDTH-1:0];
        assign w_data = if (w_ptr == {DATA_WIDTH{1'b0}}) w_ptr[DATA_WIDTH-1:0];
    end

endmodule
