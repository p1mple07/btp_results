module cvdp_copilot_apb_gpio #(parameter GPIO_WIDTH = 8)
(
    input clk,
    input preset_n,
    input psel,
    input [7:0] paddr,
    input penable,
    input pwrite,
    input [31:0] pwdata,
    input [GPIO_WIDTH-1:0] gpio_in,
    output reg [31:0] prdata,
    output reg pready,
    output reg pslverr,
    output [(GPIO_WIDTH-1):0] gpio_out,
    output [(GPIO_WIDTH-1):0] gpio_enable,
    output [(GPIO_WIDTH-1):0] gpio_int,
    output comb_int
);

    // GPIO Input Data Register (Read-Only)
    reg [(GPIO_WIDTH-1):0] reg_in_data;

    // GPIO Output Data Register
    reg [(GPIO_WIDTH-1):0] reg_out_data;

    // GPIO Output Enable Register
    reg [(GPIO_WIDTH-1):0] reg_enable_data;

    // GPIO Interrupt Enable Register
    reg [(GPIO_WIDTH-1):0] reg_int_enable_data;

    // GPIO Interrupt Type Register
    reg [(GPIO_WIDTH-1):0] reg_int_type_data;

    // GPIO Interrupt Polarity Register
    reg [(GPIO_WIDTH-1):0] reg_int_polarity_data;

    // GPIO Interrupt State Register (Read-Only)
    reg [(GPIO_WIDTH-1):0] reg_int_state_data;

    // Interrupt Logic
    assign comb_int = gpio_int | gpio_int; // Logical OR for combined interrupt signal

    // Synchronization Flip-Flop for GPIO Input
    always @(posedge clk)
        reg_in_data <= gpio_in;

    // GPIO Behavior Logic
    always @*
    begin
        case (psel)
            0: begin
                reg_out_data = reg_enable_data;
                gpio_out = reg_out_data;
                gpio_enable = ~reg_enable_data;
                gpio_int = reg_int_enable_data;
            end
            default: begin
                reg_out_data = 0;
                gpio_out = reg_out_data;
                gpio_enable = 1;
                gpio_int = 0;
            end
        endcase
    end

    // Address Decoding Logic
    always @(posedge clk)
    begin
        if (psel == 0)
        begin
            if (paddr == 0) begin
                prdata = reg_in_data;
                pslverr = 0;
            end
            else
                prdata = 0;
        end
        else
            prdata = reg_out_data;
    end

    // Interrupt Configuration Logic
    always @*
    begin
        reg_int_type_data = (pint_type == "edge");
        reg_int_polarity_data = (pint_polarity == "active_high");
        reg_int_enable_data = (pint_enable == 1);
        reg_int_state_data = (gpio_in & reg_int_enable_data);
    end

    // Reset Logic
    always @(negedge preset_n)
        begin
            reg_in_data = 0;
            reg_out_data = 0;
            reg_enable_data = 0;
            reg_int_enable_data = 0;
            reg_int_type_data = 0;
            reg_int_polarity_data = 0;
            reg_int_state_data = 0;
        end

    // Interrupt Logic for Combined Interrupt Signal
    always @(posedge clk)
    begin
        if (psel == 0)
        begin
            if (pint_enable)
                comb_int = reg_int_state_data;
            else
                comb_int = 0;
        end
    end

    // Outputs
    assign pready = 1'b1;
    assign pslverr = 0;

endmodule
