module ttc_counter_lite #(parameter WIDTH = 32) (
    input clk,
    input reset,
    input [3:0] axi_addr,
    input [31:0] axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output reg [31:0] axi_rdata,
    output reg interrupt
);

    reg [WIDTH-1:0] count = 0;
    reg [WIDTH-1:0] match_value = 0;
    reg [WIDTH-1:0] reload_value = 0;
    reg enable, interval_mode, interrupt_enable;
    reg match_flag;
    reg interrupt_asserted = 0;

    // Control Register
    assign control_reg = 32'h{enable, interval_mode, interrupt_enable};

    // Counter Logic
    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            match_flag <= 0;
            interrupt_asserted <= 0;
        end else if (enable) begin
            if (interval_mode) begin
                if (count == reload_value) begin
                    count <= 0;
                    match_flag <= 1;
                end else begin
                    count <= count + 1;
                end
            end else begin
                if (count == match_value) begin
                    match_flag <= 1;
                end else begin
                    count <= count + 1;
                end
            end
        end
    end

    // Match Detection
    always @(posedge clk) begin
        if (match_flag) begin
            interrupt_asserted <= 1;
        end else begin
            interrupt_asserted <= 0;
        end
    end

    // Interrupt Generation
    always @(posedge clk) begin
        if (interrupt_asserted && interrupt_enable) begin
            interrupt <= 1;
        end else begin
            interrupt <= 0;
        end
    end

    // AXI Interface
    always @(posedge clk) begin
        case (axi_addr)
            3'b000: begin
                axi_rdata <= count[15:0];
            end
            3'b001: begin
                match_value <= count[15:0];
            end
            3'b010: begin
                reload_value <= count[15:0];
            end
            3'b011: begin
                control_reg <= control_reg;
            end
            3'b100: begin
                interrupt_asserted <= interrupt_asserted;
            end
            default: begin
                axi_rdata <= 32'h00000000;
            end
        endcase
    end

endmodule
