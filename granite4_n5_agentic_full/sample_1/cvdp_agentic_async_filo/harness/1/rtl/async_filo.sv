module async_fifo #(
    parameter int DATA_WIDTH = 32
    ) (
    input bit clk,
    output bit full
    )
    begin
        always @ (posedge clk):
            assign full = (counter >= DEPTH)
endmodule