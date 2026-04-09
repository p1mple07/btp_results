module axi_register(
    input clock,
    input rst,
    input [ADDR_WIDTH-1:0] awaddr,
    input [DATA_WIDTH-1:0] wdata,
    input [DATA_WIDTH-1:0] wstrb,
    input wvalid,
    input bready,
    input [ADDR_WIDTH-1:0] araddr,
    input arvalid,
    input rvalid,
    input done,
    output [1:0] bresp,
    output bvalid,
    output [1:0] rresp,
    output rvalid_o,
    output rdata,
    output start_o,
    output beat_o,
    output [19:0] beat,
    output writeback_o,
    output [31:0] id_reg
);

    // AXI4-Lite protocol handshake
    reg valid_ar, valid_aw, arvalid_o, awvalid_o;

    // Address decoding
    reg [ADDR_WIDTH-1:0] address;

    // Register mappings
    reg [20:0] beat_reg;
    reg start_reg;
    reg [31:0] id_reg;
    // ... (other registers as needed)

    // Address phase for write
    always_comb begin
        if (rst) begin
            valid_ar = 1;
            valid_aw = 1;
            arvalid_o = 0;
            awvalid_o = 0;
        else if (arvalid) begin
            valid_ar = 0;
            arvalid_o = 0;
        end else if (awvalid) begin
            valid_aw = 0;
            awvalid_o = 0;
        end else begin
            valid_ar = 0;
            valid_aw = 0;
        end
    end

    // Data phase for write
    always_comb begin
        if (valid_aw && wvalid && (wstrb == (1 << DATA_WIDTH))) begin
            beat_reg = (wdata >> 12) | (wdata << 12);
            start_reg = (wdata & 1);
            beat_o = beat_reg;
            start_o = start_reg;
            writeback_o = start_reg;
            bvalid = 1;
        end else if (valid_aw && wvalid) begin
            bvalid = 0;
        end
    end

    // Address phase for read
    always_comb begin
        if (rst) begin
            valid_ar = 1;
            valid_aw = 1;
            arvalid_o = 0;
            awvalid_o = 0;
        else if (arvalid) begin
            valid_ar = 0;
            arvalid_o = 0;
        end else if (awvalid) begin
            valid_aw = 0;
            awvalid_o = 0;
        end else begin
            valid_ar = 0;
            valid_aw = 0;
        end
    end

    // Data phase for read
    always_comb begin
        if (valid_ar && arvalid) begin
            address = araddr;
            rdata_o = (id_reg >> (DATA_WIDTH - 1)) | (id_reg << (DATA_WIDTH - 1));
            rvalid_o = 1;
            rvalid = 1;
        end else if (valid_ar && arvalid) begin
            rvalid_o = 0;
        end
    end

    // Completion phase for write
    always_comb begin
        if (rst) begin
            bvalid_o = 0;
            bresp_o = 0b00;
        else if (bvalid) begin
            bvalid_o = 0;
            bresp_o = (bvalid && (start_reg == 1)) ? 2'b10 : 2'b00;
        else begin
            bvalid_o = 1;
        end
    end

    // Completion phase for read
    always_comb begin
        if (rst) begin
            rvalid_o = 0;
            rresp_o = 0b00;
        else if (rvalid) begin
            rvalid_o = 0;
            rresp_o = (rvalid && (done == 1)) ? 2'b10 : 2'b00;
        else begin
            rvalid_o = 1;
        end
    end

    // Reset handling
    always_comb begin
        if (rst) begin
            beat_o = 0;
            start_o = 0;
            writeback_o = 0;
            id_reg = 0x00010001;
            beat_reg = 0;
            rdata_o = 0;
            rvalid_o = 0;
            bvalid_o = 0;
            bresp_o = 0b00;
            rresp_o = 0b00;
            arvalid_o = 0;
            awvalid_o = 0;
        else begin
            beat_o = beat_reg;
            start_o = start_reg;
            writeback_o = start_reg;
            id_reg = 0x00010001;
            beat_reg = 0;
            rdata_o = 0;
            rvalid_o = 0;
            bvalid_o = 0;
            bresp_o = 0b00;
            rresp_o = 0b00;
            arvalid_o = 0;
            awvalid_o = 0;
        end
    end
endmodule