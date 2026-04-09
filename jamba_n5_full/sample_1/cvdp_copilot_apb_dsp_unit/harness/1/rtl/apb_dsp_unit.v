module apb_dsp_unit (
    input pclk,
    input presetn,
    input [9:0] paddr,
    input pselx,
    input penable,
    input [7:0] pwrite,
    input [7:0] pwdata,
    output reg [7:0] pready,
    output reg prdata,
    output reg [7:0] pslverr,
    output r_operand_1,
    output r_operand_2,
    output r_Enable,
    output r_write_address,
    output r_write_data
);

// ... implementation details

endmodule
