module cvdp_copilot_apb_gpio (
    parameter(pclk, preset_n, psel, paddr, penable, pwrite, pwdata, gpio_in),
    output(pready, pslverr, prdata, gpio_out, gpio_enable, gpio_int, comb_int)
);

// Register Map
reg reg_in[GPIO_WIDTH-1:0] = 0;
reg reg_out[GPIO_WIDTH-1:0] = 0;
reg reg_enable[GPIO_WIDTH-1:0] = 0;
reg reg_int[GPIO_WIDTH-1:0] = 0;
reg reg_interrupt[4:0] = 0;

// APB Read/Write Logic
always_comb begin
    case(paddr)
        0: prdata = reg_in;
        1: prdata = reg_out;
        default: prdata = 0;
    endcase
    pslverr = 0;
end

// GPIO Control Logic
always begin
    if (pwrite & !penable) begin
        reg_out = pwdata;
    end
    if (penable & !pwrite) begin
        reg_in = gpio_in;
    end
end

// Interrupt Logic
always begin
    if (pint) begin
        case(gpio_int[0])
            0: reg_interrupt[0] = 1;
            default: break;
        endcase
        // Similar cases for other interrupt bits
    end
end

// Combined Interrupt Signal
comb_int = (gpio_int[0] | gpio_int[1] | ... | gpio_int[7]);

// Synchronization
always clockbegin
    // Synchronize reg_in
    reg_in = reg_in;
    // Synchronize reg_out
    reg_out = reg_out;
    // Synchronize reg_enable
    reg_enable = reg_enable;
    // Synchronize reg_interrupt
    reg_interrupt = reg_interrupt;
    // Synchronize all outputs
    prdata = prdata;
    pready = pready;
    pslverr = pslverr;
endclock

endmodule