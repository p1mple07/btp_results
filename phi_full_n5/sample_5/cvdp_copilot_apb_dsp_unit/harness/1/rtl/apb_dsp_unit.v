module apb_dsp_unit (
    pclk, presetn, paddr, pselx, penable, pwrite, pwdata, pready, prdata, pslverr
);

    input pclk, presetn;
    input [10:0] paddr;
    input pselx, penable, pwrite;
    input [8:0] pwdata;
    output reg pready, prdata, pslverr;

    reg [8:0] r_operand_1, r_operand_2;
    reg [2:0] r_Enable;
    reg [16:0] r_write_address, r_write_data;

    // Internal registers
    reg [16:0] addr_register;
    reg [8:0] data_register;

    // Error flag
    reg [1:0] error_flag;

    // Reset block
    always @ (posedge pclk or presetn) begin
        if (presetn) begin
            pready <= 1'b0;
            prdata <= 16'b0;
            pslverr <= 1'b0;
            r_operand_1 <= 16'b0;
            r_operand_2 <= 16'b0;
            r_Enable <= 3'b0;
            r_write_address <= 17'h00000000;
            r_write_data <= 16'h00000000;
        end
    end

    // APB interface
    always @ (posedge pclk) begin
        if (pselx == 3'b001 && penable && pwrite) begin
            case (paddr)
                10'h0: begin
                    addr_register <= r_write_address;
                    data_register <= r_write_data;
                end
                10'h01: begin
                    error_flag <= 2'b0; // Invalid address
                end
                10'h02: begin
                    error_flag <= 2'b1; // Unsupported operation
                end
                10'h03: begin
                    if (r_Enable == 3'b011) begin
                        if (addr_register == 17'h00000005) begin
                            prdata <= data_register;
                        end else begin
                            error_flag <= 2'b1; // Invalid address
                        end
                    end
                end
                10'h04: begin
                    addr_register <= r_operand_1;
                    data_register <= pwdata;
                end
                10'h05: begin
                    prdata <= data_register;
                    pready <= 1'b1;
                end
                default: begin
                    error_flag <= 2'b1; // Invalid address
                end
            endcase
        end
    end

    // Error signal
    assign pslverr = error_flag;

endmodule
