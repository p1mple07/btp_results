module cvdp_copilot_apb_gpio #(parameter GPIO_WIDTH = 8) (
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

    // Registers
    reg [31:0] reg_out;
    reg [GPIO_WIDTH-1:0] reg_enable;
    reg [GPIO_WIDTH-1:0] reg_int;

    // Internal state
    reg [GPIO_WIDTH-1:0] internal_gpio_in;
    reg internal_gpio_out;
    reg internal_gpio_int_state;
    reg internal_gpio_int_mask;

    // Synchronization flip-flops
    always @(posedge pclk) begin
        internal_gpio_in <= gpio_in;
        internal_gpio_out <= reg_out;
    end

    // GPIO Input Data Register
    always @(posedge pclk) begin
        if (!preset_n) begin
            reg_out <= 0;
        end else begin
            case (paddr)
                0: reg_out <= internal_gpio_in;
                default: reg_out <= 0;
            endcase
        end
    end

    // GPIO Output Data Register
    always @(posedge pclk) begin
        if (!preset_n) begin
            reg_out <= pwdata;
        end else begin
            reg_out <= internal_gpio_out;
        end
    end

    // GPIO Output Enable Register
    always @(posedge pclk) begin
        if (!preset_n) begin
            reg_enable <= 0;
        end else begin
            reg_enable <= gpio_enable;
        end
    end

    // GPIO Interrupt Enable Register
    always @(posedge pclk) begin
        if (!preset_n) begin
            reg_int <= 0;
        end else begin
            reg_int <= gpio_int;
        end
    end

    // GPIO Interrupt Type Register
    always @(posedge pclk) begin
        if (!preset_n) begin
            // Default to level-sensitive mode
            reg_int_mask <= 1 << gpio_int;
        end else begin
            reg_int_mask <= gpio_int;
        end
    end

    // GPIO Interrupt Polarity Register
    always @(posedge pclk) begin
        if (!preset_n) begin
            // Default to active-low
            reg_int_mask <= ~reg_int_mask;
        end else begin
            reg_int_mask <= gpio_int;
        end
    end

    // GPIO Interrupt State Register
    always @(posedge pclk) begin
        if (!preset_n) begin
            internal_gpio_int_state <= 0;
        end else begin
            internal_gpio_int_state <= reg_int_mask;
        end
    end

    // Interrupt Logic
    always @(posedge penable) begin
        if (!preset_n) begin
            pslverr <= 0;
        end else begin
            pslverr <= ~internal_gpio_int_state;
        end
    end

    // Combined Interrupt Signal
    always @(posedge pclk) begin
        comb_int <= internal_gpio_int_state;
    end

    // GPIO Output Logic
    always @(posedge pclk) begin
        internal_gpio_out <= reg_out;
        gpio_out <= internal_gpio_out;
    end

    // GPIO Input Logic
    assign gpio_in = internal_gpio_in;

    // GPIO Direction Control Logic
    always @(posedge pclk) begin
        if (!preset_n) begin
            gpio_enable <= 0;
        end else begin
            gpio_enable <= reg_enable;
        end
    end

    // Interrupt Generation Logic
    always @(posedge penable) begin
        if (!preset_n) begin
            gpio_int <= reg_int_mask;
        end else begin
            gpio_int <= reg_int_mask & comb_int;
        end
    end

endmodule
