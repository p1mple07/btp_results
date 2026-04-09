module ttc_counter_lite(
    input clk,
    input reset,
    input axi_addr,
    input axi_wdata,
    input axi_write_en,
    input axi_read_en,

    output reg axi_rdata,
    output wire interrupt,

    input wire enable,
    input wire interval_mode,
    input wire interrupt_enable,

    input wire [31:0] match_value,
    input wire [31:0] reload_value,

    output reg count,
    output reg match_flag,
    output reg [31:0] reload_value_reg,
    output reg [31:0] count_reg,
    output reg [31:0] match_value_reg
);

// ... internal logic ...

endmodule
