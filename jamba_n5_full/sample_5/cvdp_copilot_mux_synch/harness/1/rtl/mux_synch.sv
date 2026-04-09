module mux_synch (
    input [7:0] data_in,
    input req,
    input dst_clk,
    input src_clk,
    input nrst,
    output reg [7:0] data_out
);

    // Synchronise the request signal to the destination clock domain
    assign req_sync = (dst_clk & ~src_clk) & req;

    // Use a simple multiplexer to select the input data
    assign data_out = (req_sync) ? data_in : 8'b0;

endmodule

module nff (
    input d_in,
    input dst_clk,
    input rst,
    output reg syncd
);

    reg [1:0] sync_reg;
    reg ready;

    always @(posedge dst_clk) begin
        ready <= ~rst;
        if (!ready) begin
            sync_reg <= 2'b00;
        end else if (sync_reg != 8'b00) begin
            sync_reg <= {d_in, 1'b0};
        end else begin
            sync_reg <= sync_reg;
        end
        syncd <= sync_reg[1];
    end

endmodule
