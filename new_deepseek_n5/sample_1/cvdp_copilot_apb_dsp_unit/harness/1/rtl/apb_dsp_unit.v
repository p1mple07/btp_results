module apb_dsp_unit(
    input wire [9:0] paddr,
    input wire pselx,
    input wire penable,
    input wire pwrite,
    input wire pwdata,
    output reg pready,
    output reg pslverr
);

    // Register definitions
    reg [7:0] r_operand_1 = 0x0;
    reg [7:0] r_operand_2 = 0x0;
    reg [7:0] r_Enable = 0x0;
    reg [7:0] r_write_address = 0x0;
    reg [7:0] r_write_data = 0x0;

    // State control
    reg state = 0; // 0: idle, 1: read, 2: write

    // APB enable and write signals
    reg [0] penable_reg = 0;
    reg [0] pwrite_reg = 0;

    // Initialize registers
    initial begin
        r_operand_1 = 0x0;
        r_operand_2 = 0x0;
        r_Enable = 0x0;
        r_write_address = 0x0;
        r_write_data = 0x0;
    end

    // State machine
    always @(state) begin
        case(state)
            0: // Idle state
                if (r_Enable == 0x0) begin
                    pready = 1;
                    pslverr = 0;
                end else if (r_Enable == 0x3) begin
                    // Write operation
                    pwrite_reg = 1;
                    pready = 1;
                    pslverr = 0;
                end else begin
                    pready = 1;
                    pslverr = 0;
                end
                state = 1;
                // Wait 2 clock cycles
                state = 2;
                state = 0;
                break;
            1: // Read operation
                prdata = (paddr & 0x000000FF);
                state = 0;
                break;
            2: // Write operation
                r_write_data = pwdata;
                r_write_address = paddr;
                state = 0;
                break;
            default:
                state = 0;
                break;
        endcase
    end

    // APB interface signals
    assign penable = penable_reg;
    assign pwrite = pwrite_reg;
endmodule