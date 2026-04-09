module apb_dsp_unit (
    pclk, presetn, paddr, pselx, penable, pwrite, pwdata, pready, prdata, pslverr
);
    input pclk, presetn;
    input [10:0] paddr, pselx, penable, pwrite, pwdata;
    output reg pready, prdata, pslverr;

    // Internal signals
    reg [8:0] r_operand_1, r_operand_2, r_Enable, r_write_address, r_write_data;

    // Configuration registers
    reg [31:0] config_registers [5:0];

    // Memory interface
    reg [7:0] sram_memory [0:1023];

    // Initialization
    initial begin
        if (!presetn) begin
            r_operand_1 = 0;
            r_operand_2 = 0;
            r_Enable = 0;
            r_write_address = 0;
            r_write_data = 0;
        end
    end

    // Functional behavior
    always @(posedge pclk) begin
        case (pselx)
            0: begin
                // Read state
                prdata <= sram_memory[paddr];
                pready <= 1'b1;
            end
            1: begin
                // Write state
                if (pwrite) begin
                    if (pslverr) begin
                        prdata <= 8'b0;
                    end else begin
                        sram_memory[r_write_address] <= r_write_data;
                    end
                    pready <= 1'b1;
                end
            end
            default: begin
                pready <= 1'b0;
            end
        endcase

        case (r_Enable)
            0: begin
                // DSP disabled
            end
            1: begin
                // Addition mode
                if (pslverr) begin
                    prdata <= sram_memory[5];
                end else begin
                    prdata <= (sram_memory[r_operand_1] + sram_memory[r_operand_2]);
                end
            end
            2: begin
                // Multiplication mode
                if (pslverr) begin
                    prdata <= sram_memory[5];
                end else begin
                    prdata <= (sram_memory[r_operand_1] * sram_memory[r_operand_2]);
                end
            end
        endcase

        // Reset behavior
        always @(posedge presetn) begin
            r_operand_1 <= 0;
            r_operand_2 <= 0;
            r_Enable <= 0;
            r_write_address <= 0;
            r_write_data <= 0;
            pready <= 1'b0;
            prdata <= 8'b0;
            pslverr <= 1'b0;
        end
    end

endmodule
