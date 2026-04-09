module apb_dsp_unit(
    pclk, presetn,
    paddr, pselx, penable, pwrite, pwdata,
    pready, prdata, pslverr
);

    input pclk;
    input presetn;
    input [10:0] paddr;
    input pselx, penable, pwrite;
    input [8:0] pwdata;
    output reg pready;
    output reg [8:0] prdata;
    output reg pslverr;

    reg [10:0] r_operand_1;
    reg [10:0] r_operand_2;
    reg [2:0] r_Enable;
    reg [31:0] r_write_address;
    reg [31:0] r_write_data;

    reg [10:0] computed_result;

    // Internal Registers
    reg [10:0] r_operand_1_reg;
    reg [10:0] r_operand_2_reg;
    reg r_Enable_reg;
    reg r_write_address_reg;
    reg r_write_data_reg;

    // Memory and SRAM Interface
    reg [31:0] sram [0:31];

    // Reset logic
    always @(posedge presetn) begin
        pready <= 1'b1;
        prdata <= 32'h00000000;
        pslverr <= 1'b0;

        r_operand_1_reg <= 32'h00000000;
        r_operand_2_reg <= 32'h00000000;
        r_Enable_reg <= 3'd0;
        r_write_address_reg <= 32'h00000000;
        r_write_data_reg <= 32'h00000000;
    end

    // APB Interface Control
    always @(posedge pclk) begin
        if (presetn == 1'b0) begin
            if (penable && pwrite) begin
                r_write_address_reg <= r_write_address;
                r_write_data_reg <= r_write_data;
                sram[r_write_address_reg] <= r_write_data_reg;
            end
        end

        if (penable && pwrite) begin
            r_write_address_reg <= r_operand_1_reg;
            r_write_data_reg <= r_operand_2_reg;
            computed_result <= (r_Enable_reg == 3'd1 ? r_operand_1_reg + r_operand_2_reg : r_operand_1_reg * r_operand_2_reg);
            r_write_address_reg <= 32'h00000005;
            r_write_data_reg <= computed_result;
            pready <= 1'b0;
            prdata <= computed_result;
            pslverr <= 1'b0;
        end
    end

endmodule
