module axi_register(
    input clock,
    input rst,
    input [ADDR_WIDTH-1:0] awaddr,
    input [DATA_WIDTH-1:0] wdata,
    input [DATA_WIDTH/8-1:0] wstrb,
    input wvalid,
    input bready,
    input [ADDR_WIDTH-1:0] araddr,
    input arvalid,
    input rready,
    input done
);

    // Configuration parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;

    // Register map
    reg [19:0] beat = 0x00000000;
    reg start = 0;
    reg [1:0] done_reg = {0, 0};
    reg writeback = 0;
    reg [32-1:0] id = 0x00010000;

    // AXI4-Lite initialization
    always_comb begin
        if (rst) begin
            beat = 0;
            start = 0;
            done_reg = {0, 0};
            writeback = 0;
            id = 0x00010000;
            $valid_out(0);
            $ready_out(1);
        end

        // Write operation
        if (arvalid && wvalid) begin
            $valid_out(wvalid);
            if (wstrb[0]) begin
                if (wvalid) begin
                    beat = (beat + wdata) & ((1 << DATA_WIDTH) - 1);
                    start = (wdata & 1) ? 1 : 0;
                    done_reg[0] = ~done_reg[0];
                    writeback = (wdata & 1) ? 1 : 0;
                end
            end
            $ready_out(0);
        end

        // Read operation
        if (arvalid && arvalid) begin
            $valid_out(arvalid);
            rdata = beat;
            done_reg[1] = ~done_reg[1];
            $ready_out(0);
        end
    end

    // Error handling
    wire [2:0] bresp = {0, 0};
    wire [1:0] rresp = {0, 0};

    // Outputs
    output awready, wready, bresp, bvalid, arready, wvalid, rvalid, rdata, rresp, start, done, writeback;
endmodule