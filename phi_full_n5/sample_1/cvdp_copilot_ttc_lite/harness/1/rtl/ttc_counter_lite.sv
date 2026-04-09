module ttc_counter_lite #(
    parameter WIDTH_COUNT = 32,
    parameter WIDTH_MATCH = 32,
    parameter WIDTH_RELOAD = 32
) (
    input clk,
    input reset,
    input [4:0] axi_addr,
    input [31:0] axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output reg [WIDTH_COUNT-1:0] count,
    output reg interrupt
);

    // Register map
    reg [WIDTH_COUNT-1:0] count_reg;
    reg [WIDTH_MATCH-1:0] match_value_reg;
    reg [WIDTH_RELOAD-1:0] reload_value_reg;
    reg [WIDTH_COUNT-1:0] control_reg;
    reg [WIDTH_COUNT-1:0] status_reg;

    // Interrupt flag
    logic match_flag;

    // Counter logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            match_value_reg <= 0;
            reload_value_reg <= 0;
            control_reg <= 0;
            status_reg <= 0;
            interrupt <= 0;
            match_flag <= 0;
        end else begin
            if (axi_write_en && axi_addr == 0x3) begin
                match_value_reg <= axi_wdata;
            end
            if (axi_write_en && axi_addr == 0x2) begin
                reload_value_reg <= axi_wdata;
            end
            if (axi_write_en && axi_addr == 0x4) begin
                control_reg <= axi_wdata;
            end
            if (axi_read_en) begin
                count_reg <= status_reg;
                match_flag <= status_reg & (count_reg == match_value_reg);
                interrupt <= match_flag & control_reg[3];
            end
            if (control_reg[3] == 1'b1) begin
                if (match_flag) begin
                    count_reg <= reload_value_reg;
                    status_reg <= 0;
                end else begin
                    count_reg <= count_reg + 1'b1;
                end
            end
        end
    end

endmodule
