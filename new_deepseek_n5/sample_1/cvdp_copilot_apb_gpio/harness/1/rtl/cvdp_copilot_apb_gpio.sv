module cvdp_copilot_apb_gpio (
    parameter GPIO_WIDTH = 8,
    input pclk,
    input preset_n,
    input psel,
    input paddr[7:2],
    input penable,
    input pwrite,
    input pwdata[31:0],
    input	gpio_in[GPIO_WIDTH-1:0]
    output reg prdata[31:0],
    output reg pready,
    output reg pslverr,
    output reg8 reg_out[0..GPIO_WIDTH-1],
    output reg8 reg_enable[0..GPIO_WIDTH-1],
    output reg8 reg_int[0..GPIO_WIDTH-1],
    output reg comb_int
);

// Register Map
reg8 reg0[0..7] = 0; // GPIO Input Data
reg8 reg4[0..7] = 0; // GPIO Output Data
reg8 reg8[0..7] = 0; // GPIO Output Enable
reg8 reg12[0..7] = 0; // GPIO Interrupt Enable
reg8 reg16[0..7] = 0; // GPIO Interrupt Type
reg8 reg20[0..7] = 0; // GPIO Interrupt Polarity
reg8 reg24[0..7] = 0; // GPIO Interrupt State

// APB Read Operation
if (penable & pwrite) begin
    case (paddr[2:0])
        3: reg0 = pwdata;
        2: reg4 = pwdata;
        1: reg8 = pwdata;
        0: reg12 = pwdata;
    endcase
end

// APB Write Operation
else if (pwrite & paddr[2:0] == 3) begin
    case (paddr[2:0])
        3: reg0 = pwdata;
        2: reg4 = pwdata;
        1: reg8 = pwdata;
        0: reg12 = pwdata;
    endcase
end

// GPIO Output Control
reg_out[0..7] = reg4 & reg_enable[0..7];

// Synchronize GPIO Input
always positive_edge clock begin
    reg8 temp_reg = reg0;
    reg0 = reg0 ^ (pclk & (temp_reg ^ reg0));
end

// Interrupt Handling
always positive_edge clock begin
    case (psel)
        0: // No Interrupt
            break;
    endcase

    // Configure Interrupt
    integer pin;
    integer addr = paddr[3:0];
    integer type = reg16[addr];
    integer polarity = reg14[addr];
    integer state = reg24[addr];

    if (type == 0) // Edge-Sensitive
        case (polarity)
            0: // Active-High
                if (state & 1) begin
                    reg_int[addr] = 1;
                    state = state ^ 1;
                end
            1: // Active-Low
                if ((state & 1) == 0) begin
                    reg_int[addr] = 1;
                    state = state ^ 1;
                end
        endcase
    else // Level-Sensitive
        if (type == 1) begin
            reg_int[addr] = (polarity == 0) ? (reg8[addr] & 1) : (~reg8[addr] & 1);
        end
        else
            reg_int[addr] = (polarity == 0) ? (reg8[addr] & 1) : (~reg8[addr] & 1);
    endcase
end

// Combine Interrupts
comb_int = reg_int[0] | reg_int[1] | reg_int[2] | reg_int[3] | reg_int[4] | reg_int[5] | reg_int[6] | reg_int[7];

endmodule