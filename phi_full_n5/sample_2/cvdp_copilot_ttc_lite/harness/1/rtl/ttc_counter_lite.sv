module ttc_counter_lite #(
    parameter WIDTH_COUNT = 32,
    parameter WIDTH_MATCH_VALUE = 32,
    parameter WIDTH_RELOAD_VALUE = 32
) (
    input clk,
    input reset,
    input [AXI_ADDR_WIDTH-1:0] axi_addr,
    input [AXI_WDATA_WIDTH-1:0] axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output reg [AXI_RDATA_WIDTH-1:0] axi_rdata,
    output reg interrupt
);

    reg [WIDTH_COUNT-1:0] count;
    reg [WIDTH_MATCH_VALUE-1:0] match_value;
    reg [WIDTH_RELOAD_VALUE-1:0] reload_value;
    reg enable, interval_mode, interrupt_enable;
    reg match_flag;
    reg [WIDTH_STATUS_WIDTH-1:0] status;

    // Initialize all registers to reset state
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= {WIDTH_COUNT{1'b0}};
            match_value <= {WIDTH_MATCH_VALUE{1'b0}};
            reload_value <= {WIDTH_RELOAD_VALUE{1'b0}};
            enable <= 1'b0;
            interval_mode <= 1'b0;
            interrupt_enable <= 1'b0;
            match_flag <= 1'b0;
            status <= {WIDTH_STATUS_WIDTH{1'b0}};
        end else begin
            if (enable) begin
                if (interval_mode) begin
                    if (match_value == count) begin
                        match_flag <= 1'b1;
                    end else begin
                        match_flag <= 1'b0;
                    end
                end else begin
                    if (match_value == count) begin
                        count <= reload_value;
                    end else {
                        count <= count + 1;
                    }
                end
            end
        end
    end

    // AXI-Lite interface
    always @(posedge clk) begin
        if (axi_write_en && axi_addr == AXI_WRITE_ADDR) begin
            match_value <= axi_wdata;
        end
        if (axi_read_en && axi_addr == AXI_READ_ADDR) begin
            axi_rdata <= count[WIDTH_COUNT-1:0];
        end
    end

    // Interrupt logic
    always @(posedge clk) begin
        if (match_flag && interrupt_enable) begin
            interrupt <= 1'b1;
        end else begin
            interrupt <= 1'b0;
        end
    end

    // Status register logic
    always @(posedge clk) begin
        if (reset) begin
            status <= {WIDTH_STATUS_WIDTH{1'b0}};
        end else begin
            status <= (match_flag == 1'b1) ? {WIDTH_STATUS_WIDTH{1'b1}} : {WIDTH_STATUS_WIDTH{1'b0}};
        end
    end

    // Control register logic
    always @(posedge clk) begin
        if (reset) begin
            enable <= 1'b0;
            interval_mode <= 1'b0;
            interrupt_enable <= 1'b0;
        end else begin
            enable <= axi_write_en;
            interval_mode <= match_value != 0;
            interrupt_enable <= match_value != 0;
        end
    end

endmodule
