module apb_dsp_unit (
    pclk, presetn,
    paddr, pselx, penable, pwrite, pwdata,
    pready, prdata, pslverr
);

    input pclk;
    input presetn;
    input [10:0] paddr;
    input pselx, penable, pwrite;
    input [8:0] pwdata;
    output pready, prdata, pslverr;

    // Registers
    reg [7:0] r_operand_1, r_operand_2, r_Enable, r_write_address, r_write_data;
    reg [7:0] computed_data;

    // Reset logic
    always @(posedge presetn) begin
        r_operand_1 <= 8'h0;
        r_operand_2 <= 8'h0;
        r_Enable <= 8'h0;
        r_write_address <= 16'h00000000;
        r_write_data <= 16'h00000000;
        pready <= 1'b1;
        prdata <= 8'h00000000;
        pslverr <= 1'b0;
    end

    // SRAM Interface
    reg [7:0] sram_valid;

    // APB Protocol
    always @(posedge pclk) begin
        if (presetn == 1'b0) begin
            // Reset logic
        end else begin
            case (paddr)
                10'h0000: begin
                    // Read operation
                    prdata <= r_operand_1;
                    pready <= 1'b1;
                    pslverr <= 1'b0;
                end
                10'h0001: begin
                    // Read operation
                    prdata <= r_operand_2;
                    pready <= 1'b1;
                    pslverr <= 1'b0;
                end
                10'h0010: begin
                    // Read operation
                    prdata <= r_Enable;
                    pready <= 1'b1;
                    pslverr <= 1'b0;
                end
                10'h0011: begin
                    // Write operation
                    r_write_address <= paddr;
                    r_write_data <= pwdata;
                    sram_valid <= 1'b1;
                    pready <= 1'b0;
                    pslverr <= 1'b0;
                end
                10'h0100: begin
                    // Write operation
                    computed_data <= r_operand_1 + r_operand_2;
                    sram_valid <= 1'b1;
                    r_write_address <= 16'h00000005;
                    r_write_data <= computed_data;
                    pready <= 1'b0;
                    pslverr <= 1'b0;
                end
                10'h0101: begin
                    // Write operation
                    computed_data <= r_operand_1 * r_operand_2;
                    sram_valid <= 1'b1;
                    r_write_address <= 16'h00000005;
                    r_write_data <= computed_data;
                    pready <= 1'b0;
                    pslverr <= 1'b0;
                end
                default: begin
                    pslverr <= 1'b1;
                end
            endcase
        end
    end

    // Outputs
    assign prdata = (pwrite == 1'b0) ? computed_data : 8'h00000000;

endmodule
