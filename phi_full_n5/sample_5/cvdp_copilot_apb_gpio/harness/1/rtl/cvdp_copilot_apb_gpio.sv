module cvdp_copilot_apb_gpio #(parameter GPIO_WIDTH = 8)
(
    input wire pclk,
    input wire preset_n,
    input wire psel,
    input wire [7:0] paddr,
    input wire penable,
    input wire pwrite,
    input wire [31:0] pwdata,
    input wire [GPIO_WIDTH-1:0] gpio_in,
    output reg [31:0] prdata,
    output reg pready,
    output reg pslverr,
    output reg [GPIO_WIDTH-1:0] gpio_out,
    output reg [GPIO_WIDTH-1:0] gpio_enable,
    output reg [GPIO_WIDTH-1:0] gpio_int,
    output reg comb_int
);

    // Input/Output Flip-Flops for GPIO Input Synchronization
    reg [GPIO_WIDTH-1:0] gpio_sync_in;

    // Register Map
    reg [31:0] reg_out;
    reg [GPIO_WIDTH-1:0] reg_enable;
    reg [GPIO_WIDTH-1:0] reg_int_type;
    reg [GPIO_WIDTH-1:0] reg_int_polarity;
    reg [GPIO_WIDTH-1:0] reg_int_status;

    // Interrupt Logic
    logic [GPIO_WIDTH-1:0] combined_interrupt;

    // Internal Synchronization Logic
    always @(posedge pclk or posedge preset_n) begin
        if (preset_n) begin
            reg_out <= 0;
            reg_enable <= 0;
            reg_int_type <= 0;
            reg_int_polarity <= 0;
            reg_int_status <= 0;
            gpio_sync_in <= 0;
            gpio_out <= 0;
            gpio_enable <= 0;
            gpio_int <= 0;
            comb_int <= 0;
        end else begin
            reg_out <= gpio_in;
            reg_enable <= gpio_out[GPIO_WIDTH-1];
            reg_int_type <= reg_int_type[GPIO_WIDTH-1];
            reg_int_polarity <= reg_int_polarity[GPIO_WIDTH-1];
            reg_int_status <= reg_int_status[GPIO_WIDTH-1];
            gpio_sync_in <= gpio_sync_in[GPIO_WIDTH-1];
            gpio_out <= reg_out;
            gpio_enable <= reg_enable;
            gpio_int <= reg_int_status;
            combined_interrupt <= reg_int_status;
        end
    end

    // Address Decoding
    always @(posedge pclk or posedge preset_n) begin
        case (paddr)
            8'h00: prdata <= reg_out;
            default: prdata <= 32'h00000000;
        endcase
    end

    // GPIO Output Enable Control
    always @(posedge pclk or posedge preset_n) begin
        if (pwrite & penable & ~preset_n) begin
            reg_out <= pwdata;
        end
    end

    // GPIO Interrupt Enable Control
    always @(posedge pclk or posedge preset_n) begin
        if (pwrite & penable & ~preset_n) begin
            reg_int_status <= reg_int_type & reg_int_polarity;
        end
    end

    // Interrupt Logic
    always @(posedge pclk or posedge preset_n) begin
        if (reg_int_status) begin
            pslverr <= 0;
            comb_int <= combined_interrupt;
        end else begin
            pslverr <= 1;
            comb_int <= 0;
        end
    end

    // Output Registers
    assign pready = 1'b1;
    assign pslverr = reg_int_status;
    assign gpio_out = reg_out;
    assign gpio_enable = reg_enable;

    // Documentation
    // Module Name: cvdp_copilot_apb_gpio
    // Parameters:
    // - GPIO_WIDTH: Number of GPIO pins (8 by default)
    // Inputs:
    // - pclk: Clock signal
    // - preset_n: Active-low reset
    // - psel: APB peripheral select signal
    // - paddr: APB address bus
    // - penable: Transfer control signal
    // - pwrite: Write control signal
    // - pwdata: Write data bus
    // - gpio_in: Input signals from GPIO pins
    // Outputs:
    // - prdata: Read data bus
    // - pready: Always high
    // - pslverr: Always low
    // - gpio_out: Output signals to GPIO pins
    // - gpio_enable: Direction control signals
    // - gpio_int: Individual interrupt signals
    // - comb_int: Combined interrupt signal

endmodule
