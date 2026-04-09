module axi_register #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input clk_i,
    input rst_n_i,
    input awaddr_i,
    input awvalid_i,
    input wdata_i,
    input wstrb_i,
    input wvalid_i,
    input bready_i,
    input araddr_i,
    input arvalid_i,
    input done_i,
    output awready_o,
    output wready_o,
    output bresp_o,
    output bvalid_o,
    output arready_o,
    output rdata_o,
    output rvalid_o,
    output rresp_o,
    output beat_o,
    output start_o,
    output writeback_o
);

reg [ADDR_WIDTH-1:0] awaddr;
reg [DATA_WIDTH-1:0] wdata;
reg [1:0] bresp;
reg bvalid;
reg arready;
reg rvalid;
reg rresp;
reg beat;
reg start;
reg writeback;

always_ff @(posedge clk_i) begin
    if (rst_n_i) begin
        awaddr <= 32'd0;
        wdata <= 32'd0;
        bresp <= 2'b00;
        bvalid <= 0;
        arready <= 0;
        rvalid <= 0;
        rresp <= 2'b00;
        beat <= 0;
        start <= 0;
        writeback <= 0;
    end else begin
        awready <= awvalid;
        arready <= arvalid;

        if (awvalid && !awready) awready <= 1;
        if (arvalid && !arready) arready <= 1;

        if (awvalid && !awready) begin
            awready <= 1;
            awready_o <= 0;
        end

        if (arvalid && !arready) begin
            arready <= 1;
            arready_o <= 0;
        end

        if (awvalid && !awready) begin
            awaddr <= awaddr_i;
            wdata <= wdata_i;
            bresp <= 2'b00;
            bvalid <= 0;
            bvalid_o <= 0;
        end else if (awready && !awvalid) begin
            awready <= awvalid;
            awready_o <= 0;
        end

        // Handle read
        if (arvalid && !arready) begin
            arready <= 1;
            arready_o <= 0;
        end else if (arready && !arvalid) begin
            arready <= 0;
        end

        if (arvalid && !arready) begin
            arready <= 1;
            arready_o <= 0;
        end

        if (arready && !arvalid) begin
            arready <= 0;
        end

        if (arvalid && !arready) begin
            // read data
            rdata_o <= wdata;
            rvalid <= 1;
            rvalid_o <= 1;
        end else if (arready && !arvalid) begin
            rdata_o <= 32'd0;
            rvalid <= 0;
            rvalid_o <= 0;
        end

        if (arready && !arvalid) begin
            // error
            rresp <= 2'b10;
            rresp_o <= 1;
        end else if (arready && !arvalid) begin
            // error
            rresp <= 2'b10;
            rresp_o <= 1;
        end

        if (arready && !arvalid) begin
            // invalid address
            rresp <= 2'b10;
            rresp_o <= 1;
        end else if (arready && !arvalid) begin
            rresp <= 2'b10;
            rresp_o <= 1;
        end

        if (arready && !arvalid) begin
            // invalid address
            rresp <= 2'b10;
            rresp_o <= 1;
        end else if (arready && !arvalid) begin
            rresp <= 2'b10;
            rresp_o <= 1;
        end

        // write
        if (wvalid && !wready) begin
            wready <= 1;
            wvalid <= 0;
            bresp <= 2'b00;
            bvalid <= 0;
            beat <= beat + 1; // simple increment, but we need 20 bits
            beat_o <= beat + 1;
        end else if (wvalid && !wready) begin
            wready <= 1;
            wvalid <= 0;
            bresp <= 2'b00;
            bvalid <= 0;
            beat <= beat + 1;
            beat_o <= beat + 1;
        end else if (wvalid && !wready) begin
            wready <= 1;
            wvalid <= 0;
            bresp <= 2'b00;
            bvalid <= 0;
            beat <= beat + 1;
            beat_o <= beat + 1;
        end else if (wvalid && !wready) begin
            wready <= 1;
            wvalid <= 0;
            bresp <= 2'b00;
            bvalid <= 0;
            beat <= beat + 1;
            beat_o <= beat + 1;
        end

        if (wready && !wvalid) begin
            wvalid <= 1;
            wvalid_o <= 1;
        end else if (wready && !wvalid) begin
            wvalid <= 0;
            wvalid_o <= 0;
        end

        if (wready && !wvalid) begin
            wvalid <= 1;
            wvalid_o <= 1;
        end else if (wready && !wvalid) begin
            wvalid <= 0;
            wvalid_o <= 0;
        end

        if (wvalid && !wready) begin
            wready <= 1;
            wvalid <= 0;
            bresp <= 2'b00;
            bvalid <= 0;
            beat <= beat + 1;
            beat_o <= beat + 1;
        end else if (wvalid && !wready) begin
            wready <= 1;
            wvalid <= 0;
            bresp <= 2'b00;
            bvalid <= 0;
            beat <= beat + 1;
            beat_o <= beat + 1;
        end

        if (wready && !wvalid) begin
            wvalid <= 1;
            wvalid_o <= 1;
        end else if (wready && !wvalid) begin
            wvalid <= 0;
            wvalid_o <= 0;
        end

        // start pulse
        if (start_o) begin
            start <= 1;
        end else if (start && !start_o) begin
            start <= 0;
        end
    end
end

assign awready_o = awvalid;
assign arready_o = arvalid;
