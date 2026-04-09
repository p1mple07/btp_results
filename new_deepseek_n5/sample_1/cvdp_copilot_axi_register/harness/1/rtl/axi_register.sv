module axi_register(
    parameter ADDR_WIDTH,
    parameter DATA_WIDTH,
    input clock_i,
    input rst_n_i,
    input [ADDR_WIDTH-1:0] awaddr_i,
    input [DATA_WIDTH-1:0] wdata_i,
    input [DATA_WIDTH/8-1:0] wstrb_i,
    input wvalid_i,
    input bready_i,
    input [ADDR_WIDTH-1:0] araddr_i,
    input arvalid_i,
    output arready_o,
    output [DATA_WIDTH-1:0] rdata_o,
    output rvalid_o,
    output [1:0] rresp_o,
    output [1:0] bresp_o,
    output beat_o,
    output start_o,
    output done_o,
    output writeback_o,
    output [31:0] id_reg
);

    // AXI handshake signals
    output arvalid_o;
    output arready_o;
    output awvalid_o;
    output awready_o;
    output bvalid_o;
    output bready_i;
    output wvalid_o;
    output wready_o;

    // Beat counter
    reg [19:0] beat_reg;

    // ID register
    reg [31:0] id_reg;

    // Start signal
    reg start_o;

    // Done status
    reg done_o;

    // Writeback signal
    reg writeback_o;

    // Address decoding
    reg [23:0] axi_address;

    // Beat address generator
    reg beat_addr;

    // AXI to module ports
    wire arvalid_o = arvalid_i;
    wire arready_o = arready_i;
    wire awvalid_o = awvalid_i;
    wire awready_o = awready_i;
    wire bvalid_o = bvalid_i;
    wire bready_i = bready_i;
    wire wvalid_o = wvalid_i;
    wire wready_o = wready_i;

    // Initialize registers
    always @* begin
        if (rst_n_i) begin
            beat_o = 0;
            start_o = 0;
            done_o = 0;
            writeback_o = 0;
            id_reg = 0x00010001;
        end
    end

    // Write transaction
    always @*+begin
        if (awvalid_i) begin
            awready_o = 1;
            // Address phase
            axi_address = [ADDR_WIDTH-1:0] awaddr_i;
            // Data phase
            if (wvalid_i) begin
                // Update beat counter
                beat_o = wdata_i;
                // Set start signal
                start_o = (wdata_i & 1) & wstrb_i[0];
                // Set done signal
                done_o = ~ (wdata_i & 1);
                // Set writeback signal
                writeback_o = (wdata_i & 1) & wstrb_i[0];
                // Update register
                beat_reg = wdata_i;
            end
            // Acknowledge write
            bresp_o = 2'b00;
            bvalid_o = 1;
        end
    end

    // Read transaction
    always @*+begin
        if (arvalid_i) begin
            arready_o = 1;
            // Address phase
            axi_address = [ADDR_WIDTH-1:0] araddr_i;
            // Data phase
            // Update beat counter
            beat_o = beat_reg;
            // Get done status
            done_o = arvalid_i & (beat_o & 1);
            // Read data
            rdata_o = (beat_reg < DATA_WIDTH) ? beat_reg[DATA_WIDTH-1:0] : 0;
            // Acknowledge read
            rresp_o = 2'b00;
            rvalid_o = 1;
        end
    end

    // Invalid address handling
    always @*+begin
        if (!arvalid_i && !awvalid_i) begin
            // Invalid address
            rresp_o = 2'b10;
        end
    end

    // Write to ID register
    always @*+begin
        if (wvalid_i && wstrb_i[0]) begin
            // Write to ID register
            id_reg = wdata_i;
            // Generate error
            bresp_o = 2'b10;
            bvalid_o = 1;
        end
    end
endmodule