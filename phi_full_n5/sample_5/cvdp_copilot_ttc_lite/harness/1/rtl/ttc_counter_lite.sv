module ttc_counter_lite #(parameter WIDTH = 32) (
    input clk,
    input reset,
    input [3:0] axi_addr,
    input [WIDTH-1:0] axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output reg [WIDTH-1:0] axi_rdata,
    output reg interrupt
);

    // Registers
    reg [WIDTH-1:0] count = 0;
    reg [WIDTH-1:0] match_value = 0;
    reg [WIDTH-1:0] reload_value = 0;
    reg [WIDTH-1:0] enable = 1'b0;
    reg [WIDTH-1:0] interval_mode = 1'b0;
    reg [WIDTH-1:0] interrupt_enable = 1'b0;
    reg [WIDTH-1:0] match_flag = 0;
    reg [WIDTH-1:0] status = 1'b0;

    // Counter logic
    always @(posedge clk) begin
        if (!reset) begin
            count <= 0;
            match_value <= 0;
            reload_value <= 0;
            enable <= 1'b0;
            interval_mode <= 1'b0;
            interrupt_enable <= 1'b0;
            match_flag <= 0;
            status <= 1'b0;
        end else if (axi_addr == 4'b0000) begin
            if (axi_write_en && axi_read_en) begin
                match_value <= axi_wdata;
            end
        end else if (axi_addr == 4'b0001) begin
            if (axi_write_en && axi_read_en) begin
                reload_value <= axi_wdata;
            end
        end else if (axi_addr == 4'b0010) begin
            enable <= axi_wdata;
        end else if (axi_addr == 4'b0011) begin
            interval_mode <= axi_wdata;
        end else if (axi_addr == 4'b0100) begin
            interrupt_enable <= axi_wdata;
        end

        // Counter increment and match detection
        if (enable) begin
            if (interval_mode) begin
                if (count == match_value) begin
                    match_flag <= 1;
                end else begin
                    count <= count + 1'b1;
                end
            end else begin
                count <= match_value;
            end
        end

        // Interrupt generation
        if (match_flag && interrupt_enable) begin
            interrupt <= 1'b1;
            match_flag <= 0;
        end else begin
            interrupt <= 1'b0;
        end

        // Clear interrupt on write to status register
        if (axi_addr == 4'b0101) begin
            status <= 1'b0;
        end
    end

    // AXI-Lite interface
    always @(posedge clk) begin
        case (axi_addr)
            4'b0000: axi_rdata <= count[15:0];
            4'b0001: axi_rdata <= reload_value[15:0];
            4'b0010: axi_rdata <= enable;
            4'b0011: axi_rdata <= interval_mode;
            4'b0100: axi_rdata <= interrupt_enable;
            4'b0101: axi_rdata <= status;
            default: axi_rdata <= 32'b0;
        endcase
    end

endmodule
