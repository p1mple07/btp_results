module apb_dsp_unit (
    input wire pclk,
    input wire presetn,
    input wire paddr,
    input wire pselx,
    input wire penable,
    input wire pwrite,
    input wire pwdata,
    output reg prdata,
    output reg pready,
    output reg pslverr,
    input wire sram_valid
) {

    // State machine
    reg state = IDLE;
    reg [7:0] result;

    // Register definitions
    reg [7:0] r_operand_1, r_operand_2, r_Enable, r_write_address, r_write_data;

    // Initialize registers
    initial begin
        r_operand_1 = 0;
        r_operand_2 = 0;
        r_Enable = 0;
        r_write_address = 0;
        r_write_data = 0;
        prdata = 0;
        pready = 0;
        pslverr = 0;
    end

    // State transitions
    always @* begin
        case (state)
            IDLE:
                if (presetn) begin
                    // Reset all registers and outputs
                    prdata = 0;
                    pready = 0;
                    pslverr = 0;
                    r_operand_1 = 0;
                    r_operand_2 = 0;
                    r_Enable = 0;
                    r_write_address = 0;
                    r_write_data = 0;
                    state = IDLE;
                end
                else begin
                    // Transition to READ or WRITE state based on r_Enable
                    if (r_Enable == 0) state = IDLE;
                    else if (r_Enable == 1 || r_Enable == 2) state = READ;
                    else if (r_Enable == 3) state = WRITE;
                end
            READ:
                // Read operands and compute result
                result = r_operand_1 + r_operand_2;
                prdata = result;
                pready = 1;
                state = IDLE;
            WRITE:
                if (sram_valid) begin
                    r_write_data = pwdata;
                    prdata = 0;
                    pready = 1;
                    state = IDLE;
                else begin
                    // Error condition
                    pslverr = 1;
                    state = IDLE;
                end
            END
        endcase
    end

    // APB Interface
    wire [7:0] apb_data;
    wire [9:0] apb_addr;

    // APB to Module Interface
    apb_addr = paddr;
    apb_data = pwdata;

    // Module to APB Interface
    if (state == IDLE) begin
        prdata = 0;
        pready = 0;
        pslverr = 0;
    end
    else if (state == READ) begin
        prdata = prdata;
        pready = 1;
        pslverr = 0;
    end
    else if (state == WRITE) begin
        prdata = 0;
        pready = 1;
        pslverr = 0;
    end

    // SRAM Interface
    always @* begin
        if (sram_valid) begin
            if (pready) begin
                r_write_data = prdata;
                r_write_address = apb_addr;
                pready = 0;
            end
        end
    end
}