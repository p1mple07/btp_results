module mux_synch (
    input [7:0] data_in,
    input req,
    input dst_clk,
    input src_clk,
    input nrst,
    output reg [7:0] data_out
);

    wire data_in_sel;
    assign data_in_sel = req;

    always @(posedge dst_clk) begin
        if (src_clk) begin
            posedge data_in_sync_process;
            data_in_sync_process <= data_in;
        end
    end

    assign data_out = data_in_sel ? data_in : 8'b0;

endmodule
