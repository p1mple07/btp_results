module apb_dsp_unit;

    parameter CLK_FREQ = 100;

    input wire clk, reset;

    output reg [31:0] paddr;
    output reg [31:0] pselx;
    output reg penable;
    output reg pwrite;
    output reg pwdata;
    input reg prdata;
    output reg psdata;
    output reg pslverr;

    // internal registers
    reg [31:0] r_operand_1;
    reg [31:0] r_operand_2;
    reg [31:0] r_Enable;
    reg [31:0] r_write_address;
    reg [31:0] r_write_data;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_operand_1 <= 0;
            r_operand_2 <= 0;
            r_Enable <= 0;
            r_write_address <= 0;
            r_write_data <= 0;
        end else begin
            // wait for ready? Actually, the design is synchronous.
        end
    end

    assign paddr = paddr;
    assign pselx = pselx;
    assign penable = penable;
    assign pwrite = pwrite;
    assign pwdata = pwdata;
    assign prdata = prdata;
    assign psdata = psdata;
    assign pslverr = pslverr;

endmodule
