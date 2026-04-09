module mux_synch (
    input [7:0] data_in,
    input req,
    input dst_clk,
    input src_clk,
    input nrst,
    output reg [7:0] data_out
);

    wire req_sync;

    always @(posedge dst_clk or negedge src_clk) begin
        if (src_clk) 
            req_sync <= req;
        else
            req_sync <= 1'b0;
    end

    reg [7:0] temp_data;

    always @(posedge dst_clk) begin
        temp_data <= data_in;
    end

    assign data_out = mux4(temp_data[3:0], req_sync, 2'b00);
endmodule
