module axi_register #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32) (
    input clk_i,
    input rst_n_i,
    input [ADDR_WIDTH-1:0] awaddr_i,
    input awvalid_i,
    input [DATA_WIDTH-1:0] wdata_i,
    input wvalid_i,
    input [ADDR_WIDTH-1:0] araddr_i,
    input arvalid_i,
    output reg rready_i,
    output reg bready_i,
    output reg [ADDR_WIDTH-1:0] araddr_o,
    output reg awready_o,
    output reg wready_o,
    output reg [1:0] bresp_o,
    output reg bvalid_o,
    output reg rready_o,
    output reg rvalid_o,
    output reg [DATA_WIDTH-1:0] rdata_o,
    output reg [19:0] beat_o,
    output reg start_o,
    output reg writeback_o,
    output reg done_o,
    output reg ID_o
);

    reg [ADDR_WIDTH-1:0] addr_reg [ADDR_WIDTH/8-1:0];
    reg [DATA_WIDTH-1:0] data_reg [ADDR_WIDTH/8-1:0];

    // Initialize registers
    initial begin
        rready_i = 0;
        bready_i = 0;
        rvalid_o = 0;
        awready_o = 0;
        wready_o = 0;
        bresp_o = 2'b00;
        bvalid_o = 0;
        rready_o = 0;
        rvalid_o = 0;
        rdata_o = 0;
        beat_o = 0;
        start_o = 0;
        writeback_o = 0;
        done_o = 1;
        ID_o = 0x0000_0001;
    end

    always @(posedge clk_i or posedge rst_n_i) begin
        if (rst_n_i) begin
            rready_i <= 0;
            bready_i <= 0;
            rvalid_o <= 0;
            awready_o <= 0;
            wready_o <= 0;
            bresp_o <= 2'b00;
            bvalid_o <= 0;
            rready_o <= 0;
            rvalid_o <= 0;
            rdata_o <= 0;
            beat_o <= 0;
            start_o <= 0;
            writeback_o <= 0;
            done_o <= 1;
            ID_o <= 0x0000_0001;
        end else begin
            if (rready_i) begin
                araddr_o <= araddr_i;
                rvalid_o <= arvalid_i;
            end
            if (awready_o && awvalid_i) begin
                addr_reg[araddr_i[ADDR_WIDTH-1:1] - 1] <= awaddr_i;
                awready_o <= 0;
            end
            if (wready_o && wvalid_i) begin
                data_reg[araddr_i[ADDR_WIDTH-1:1] - 1] <= wdata_i;
                wready_o <= 0;
            end
            if (wvalid_i && (wdata_i[ADDR_WIDTH-1] == 1'b1 && wstrb_i)) begin
                if (araddr_i[ADDR_WIDTH-1] == 1'b1) begin
                    beat_o <= wdata_i[20:1];
                    start_o <= 1;
                    writeback_o <= 1;
                end
            end
            if (arready_o && arvalid_i) begin
                raddr_o <= addr_reg[araddr_i[ADDR_WIDTH-1:1] - 1];
                rvalid_o <= 1;
            end
            if (bready_i) begin
                bresp_o <= {bvalid_o, bready_i};
                bvalid_o <= 0;
            end
        end
    end

    // Behavior for read and write transactions
    // ... (Include detailed logic for handling AXI4-Lite transactions as per specification)

endmodule
