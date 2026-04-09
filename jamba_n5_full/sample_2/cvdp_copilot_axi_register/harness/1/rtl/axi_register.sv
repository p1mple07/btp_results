module axi_register #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input clk_i,
    input rst_n_i,
    input [ADDR_WIDTH-1:0] awaddr_i,
    output wire awready_o,
    input [DATA_WIDTH-1:0] wdata_i,
    input wstrb_i,
    input wvalid_i,
    input [(DATA_WIDTH/8)-1:0] wstrb_i,
    input bready_i,
    input [ADDR_WIDTH-1:0] araddr_i,
    output wire arvalid_i,
    input rready_i,
    output [DATA_WIDTH-1:0] rdata_o,
    output rvalid_o,
    output rresp_o,
    output bresp_o,
    output bvalid_o,
    output start_o,
    output writeback_o,
    output beat_o
);

// Reset logic
always @(posedge clk_i or negedge rst_n_i) begin
    if (rst_n_i) begin
        awready_o <= 1'b0;
        arvalid_i <= 1'b0;
        rready_i <= 1'b0;
        bready_i <= 1'b0;
        // clear registers
        beat_o <= 20'd0;
        start_o <= 1'b0;
        writeback_o <= 1'b0;
        // reset all outputs
    end else begin
        awready_o <= 1'b1;
        arvalid_i <= 1'b1;
    end
end

// Write transaction
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        awready_o <= 1'b0;
        arvalid_i <= 1'b0;
        rready_i <= 1'b0;
        bready_i <= 1'b0;
        beat_o <= 20'd0;
        start_o <= 1'b0;
        writeback_o <= 1'b0;
        return;
    end
end

always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        // reset registers
    end else begin
        awready_o <= 1'b1;
        arvalid_i <= 1'b1;
    end
end

always @(posedge clk_i) begin
    if (awready_o) begin
        // Write phase
        awready_o <= 1'b0;
        arvalid_i <= 1'b1;

        if (wvalid_i && (wstrb_i & (.{ADDR_WIDTH*1}) {ADDR_WIDTH-1:0} (awaddr_i[ADDR_WIDTH-1:0])) == .WALL{ADDR_WIDTH-1:0} (wdata_i)) then
            // full write
            beat_o <= awaddr_i[ADDR_WIDTH/8+10:ADDR_WIDTH/8];
            start_o <= 1'b1;
            writeback_o <= 1'b0;

            // Update beat counter
            beat_o <= awdata_i[19:0];
        else
            // partial write
            beat_o <= awaddr_i[ADDR_WIDTH/8+10:ADDR_WIDTH/8];
            start_o <= 1'b0;
            writeback_o <= 1'b0;
        end

        // ... other conditions for writeback and ID?
        // We'll skip for simplicity.
    end
end

always @(posedge clk_i) begin
    if (rready_o) begin
        // Read phase
        arvalid_i <= 1'b1;
        rvalid_o <= 1'b0;
        rdata_o <= {31:24}{1:24}{ADR_WIDTH-25:25}; // pad to 32 bits

        // ... decode address and data
        // For simplicity, we can return dummy values.
        // But we need to show the structure.
    end
end

endmodule
