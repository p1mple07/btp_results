module axi_register #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)
(
    input clk_i,
    input rst_n_i,
    input [ADDR_WIDTH-1:0] awaddr_i,
    input awvalid_i,
    input [DATA_WIDTH-1:0] wdata_i,
    input wvalid_i,
    input [DATA_WIDTH-1:0] wstrb_i,
    input bready_i,
    input [ADDR_WIDTH-1:0] araddr_i,
    input arvalid_i,
    output reg rready_o,
    output reg [ADDR_WIDTH-1:0] rdata_o,
    output reg rvalid_o,
    output [2:0] rresp_o,
    output reg [19:0] beat_o,
    output reg start_o,
    output reg writeback_o
);

    reg [ADDR_WIDTH-1:0] addr_reg [0:255];
    reg [20:0] beat_reg;
    reg [DATA_WIDTH-1:0] data_reg [0:255];
    reg done_reg;
    reg id_reg [0:31];

    // Initialization on reset
    always @(posedge clk_i or posedge rst_n_i) begin
        if (rst_n_i) begin
            rready_o = 0;
            rdata_o = {ADDR_WIDTH{1'b0}};
            rvalid_o = 0;
            rresp_o = 2'b00;
            beat_o = 0;
            start_o = 0;
            writeback_o = 0;
            addr_reg = {ADDR_WIDTH{0}};
            beat_reg = 0;
            data_reg = {ADDR_WIDTH{0}};
            done_reg = 0;
            id_reg = {32{1'b0}};
        end else begin
            rready_o = 1;
            id_reg = {32{1'b0}};
        end
    end

    // Address decoding
    always @(posedge clk_i) begin
        if (arvalid_i) begin
            addr_reg = araddr_i;
        end
    end

    // Write operation
    always @(posedge clk_i) begin
        if (awvalid_i) begin
            if (wvalid_i) begin
                if (wstrb_i) begin
                    if (addr_reg[0] == awaddr_i) begin
                        if (wdata_i[0]) begin
                            if (wdata_i == {DATA_WIDTH{1'b1}}) begin
                                beat_reg = wdata_i;
                                start_o = 1;
                                writeback_o = 1;
                                bready_i = 1;
                            end
                        end
                    end
                end
            end
        end
    end

    // Read operation
    always @(posedge clk_i) begin
        if (arvalid_i) begin
            if (addr_reg[0] == araddr_i) begin
                rdata_o = data_reg[addr_reg[0]];
                rvalid_o = 1;
                rresp_o = 2'b00;
            end else begin
                rdata_o = {ADDR_WIDTH{1'b0}};
                rvalid_o = 0;
                rresp_o = 2'b10;
            end
        end
    end

    // Write response
    always @(posedge clk_i) begin
        if (awvalid_i && wvalid_i && bready_i) begin
            if (addr_reg[0] == awaddr_i) begin
                if (wdata_i == {DATA_WIDTH{1'b1}}) begin
                    beat_reg = wdata_i;
                    done_reg = 0;
                    writeback_o = 0;
                end
            end
            bready_i = 0;
            bvalid_o = 1;
        end
    end

    // Done status update
    always @(posedge clk_i) begin
        if (done_i) begin
            done_reg = 1;
            rready_o = 0;
        end
    end

    // Reset functionality
    always @(posedge clk_i or posedge rst_n_i) begin
        if (rst_n_i) begin
            beat_o = 0;
            start_o = 0;
            writeback_o = 0;
            addr_reg = {ADDR_WIDTH{0}};
            data_reg = {ADDR_WIDTH{0}};
            done_reg = 0;
            id_reg = {32{1'b0}};
        end else begin
            rready_o = 1;
            id_reg = {32{1'b0}};
        end
    end

endmodule
