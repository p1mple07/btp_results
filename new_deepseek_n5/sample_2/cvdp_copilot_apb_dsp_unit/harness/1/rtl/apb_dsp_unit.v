module apb_dsp_unit (
    input wire pclk,
    input wire presetn,
    input wire paddr,
    input wire pselx,
    input wire penable,
    input wire pwrite,
    input wire pwdata,
    output reg prdata,
    output reg pslverr
);

    // Initialize SRAM
    reg [31:0] sram;

    // Initialize registers
    reg r_operand_1 = 0;
    reg r_operand_2 = 0;
    reg r_Enable = 0;
    reg r_write_address = 0;
    reg r_write_data = 0;

    // State machine
    reg state = IDLE;

    // Initialize SRAM on reset
    always @* begin
        if (presetn == 0)
            state = IDLE;
    end

    // Read operation
    always @* begin
        case (r_Enable)
            0: prdata = 0; pslverr = 0; state = IDLE;
            1: // Addition mode
                if (r_operand_1 >= 0x0 && r_operand_1 <= 0x3999 && r_operand_2 >= 0x0 && r_operand_2 <= 0x3999) begin
                    prdata = paddr + paddr;
                    state = IDLE;
                else begin
                    pslverr = 1;
                    state = IDLE;
                end
            2: // Multiplication mode
                if (r_operand_1 >= 0x0 && r_operand_1 <= 0x3999 && r_operand_2 >= 0x0 && r_operand_2 <= 0x3999) begin
                    prdata = paddr * paddr;
                    state = IDLE;
                else begin
                    pslverr = 1;
                    state = IDLE;
                end
            3: // Write mode
                if (r_write_address >= 0x0 && r_write_address <= 0x3999) begin
                    r_write_data = pwdata;
                    r_write_address = paddr;
                    state = IDLE;
                else begin
                    pslverr = 1;
                    state = IDLE;
                end
            default: prdata = 0; pslverr = 0; state = IDLE;
        endcase
    end

    // Initialize SRAM
    initial begin
        sram = 0;
        state = IDLE;
    end

    // Read from SRAM
    always @* begin
        case (r_Enable)
            0: prdata = 0; pslverr = 0;
            1: prdata = sram[r_operand_1]; pslverr = 0;
            2: prdata = sram[r_operand_2]; pslverr = 0;
            3: prdata = sram[r_write_address]; pslverr = 0;
        default: prdata = 0; pslverr = 0;
        state = IDLE;
    endcase
endmodule