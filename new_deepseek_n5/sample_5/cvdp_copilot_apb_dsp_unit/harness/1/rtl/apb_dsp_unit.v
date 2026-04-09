module apb_dsp_unit (
    input wire pclk,
    input wire presetn,
    input wire [9:0] paddr,
    input wire pselx,
    input wire penable,
    input wire pwrite,
    input wire [7:0] pwdata,
    output reg pready,
    output reg [7:0] prdata,
    output reg pslverr,
    input wire sram_valid
);

    // State variables
    reg state = 0; // 0: IDLE, 1: READ, 2: WRITE, 3: RESET

    // Register definitions
    reg [7:0] r_operand_1, r_operand_2, r_Enable, r_write_address, r_write_data;

    // Initialize registers to default values
    initial begin
        r_operand_1 = 0;
        r_operand_2 = 0;
        r_Enable = 0;
        r_write_address = 0;
        r_write_data = 0;
        pready = 0;
        prdata = 0;
        pslverr = 0;
    end

    // State transitions and operations
    always @(posedge pclk or presetn) begin
        if (presetn) begin
            // Reset all registers and outputs
            r_operand_1 = 0;
            r_operand_2 = 0;
            r_Enable = 0;
            r_write_address = 0;
            r_write_data = 0;
            pready = 0;
            prdata = 0;
            pslverr = 0;
        end else if (state == 0) begin
            // IDLE state: wait for operation
            pready = 0;
        end else if (state == 1) begin
            // READ state: read result from 0x5
            prdata = 0x5;
            state = 0;
        end else if (state == 2) begin
            // WRITE state: perform operation
            case (r_Enable)
                0: // Disabled
                    r_operand_1 = 0;
                    r_operand_2 = 0;
                    r_Enable = 0;
                    r_write_address = 0;
                    r_write_data = 0;
                    state = 0;
                    break;
                1: // Addition mode
                    r_operand_1 = 0;
                    r_operand_2 = 0;
                    r_Enable = 1;
                    r_write_address = 0;
                    r_write_data = 0;
                    state = 0;
                    break;
                2: // Multiplication mode
                    r_operand_1 = 0;
                    r_operand_2 = 0;
                    r_Enable = 2;
                    r_write_address = 0;
                    r_write_data = 0;
                    state = 0;
                    break;
                3: // Write mode
                    r_operand_1 = 0;
                    r_operand_2 = 0;
                    r_Enable = 3;
                    r_write_address = 0;
                    r_write_data = 0;
                    state = 0;
                    break;
            endcase
            // Perform operation based on r_Enable value
            case (r_Enable)
                0, 1, 2: // No operation needed
                    state = 0;
                    break;
                3: // Write mode
                    // Store r_write_data at r_write_address
                    r_write_address = r_write_address;
                    r_write_data = r_write_data;
                    state = 0;
                    break;
            endcase
        end else if (state == 3) begin
            // RESET state: initialize all registers
            r_operand_1 = 0;
            r_operand_2 = 0;
            r_Enable = 0;
            r_write_address = 0;
            r_write_data = 0;
            pready = 0;
            prdata = 0;
            pslverr = 0;
            state = 0;
        end
    end

    // Error handling for invalid addresses
    if (paddr < 0 || paddr > 0x5) begin
        pslverr = 1;
    end
endmodule