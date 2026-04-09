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

    // Input/Output Interfaces
    reg [31:0] reg_out;
    reg [GPIO_WIDTH-1:0] gpio_in_sync;

    // Register Map
    reg [GPIO_WIDTH-1:0] reg_gpio_in [0:GPIO_WIDTH-1];
    reg [GPIO_WIDTH-1:0] reg_gpio_out [0:GPIO_WIDTH-1];
    reg [GPIO_WIDTH-1:0] reg_gpio_enable [0:GPIO_WIDTH-1];
    reg [GPIO_WIDTH-1:0] reg_gpio_int [0:GPIO_WIDTH-1];

    // Instantiate flip-flops for synchronization
    always @(posedge pclk) begin
        gpio_in_sync <= gpio_in;
    end

    // APB Read/Write Logic
    always @(posedge pclk) begin
        if (preset_n) begin
            reg_out <= 0;
            pready <= 1'b1;
            pslverr <= 1'b0;
        end else begin
            case (paddr)
                0: reg_out <= reg_gpio_in[0];
                1: reg_out <= reg_gpio_in[1];
                2: reg_out <= reg_gpio_in[2];
                3: reg_out <= reg_gpio_in[3];
                4: reg_out <= reg_gpio_in[4];
                5: reg_out <= reg_gpio_in[5];
                6: reg_out <= reg_gpio_in[6];
                7: reg_out <= reg_gpio_in[7];
                8: reg_out <= reg_gpio_out[0];
                9: reg_out <= reg_gpio_out[1];
                10: reg_out <= reg_gpio_out[2];
                11: reg_out <= reg_gpio_out[3];
                12: reg_out <= reg_gpio_out[4];
                13: reg_out <= reg_gpio_out[5];
                14: reg_out <= reg_gpio_out[6];
                15: reg_out <= reg_gpio_out[7];
                16: reg_out <= reg_gpio_enable[0];
                17: reg_out <= reg_gpio_enable[1];
                18: reg_out <= reg_gpio_enable[2];
                19: reg_out <= reg_gpio_enable[3];
                20: reg_out <= reg_gpio_enable[4];
                21: reg_out <= reg_gpio_enable[5];
                22: reg_out <= reg_gpio_enable[6];
                23: reg_out <= reg_gpio_enable[7];
                24: reg_out <= reg_gpio_int[0];
                25: reg_out <= reg_gpio_int[1];
                26: reg_out <= reg_gpio_int[2];
                27: reg_out <= reg_gpio_int[3];
                28: reg_out <= reg_gpio_int[4];
                29: reg_out <= reg_gpio_int[5];
                30: reg_out <= reg_gpio_int[6];
                31: reg_out <= reg_gpio_int[7];
                default: reg_out <= 0;
            endcase
        end
    end

    // GPIO Behavior
    assign gpio_out = reg_out;
    assign gpio_enable = reg_gpio_enable;
    assign gpio_int = reg_gpio_int;
    assign comb_int = reg_gpio_int | reg_gpio_int;

    // Interrupt Logic
    always @(posedge pclk) begin
        if (psel) begin
            case (paddr)
                0: begin
                    reg_gpio_int[0] <= pwrite & gpio_in_sync;
                    reg_gpio_int[1] <= ~pwrite & gpio_in_sync;
                    reg_gpio_enable[0] <= pwrite;
                    reg_gpio_enable[1] <= ~pwrite;
                    reg_gpio_int[2:7] <= 1'b0;
                end
                default: reg_gpio_int[0:7] <= 1'b0;
            endcase
        end
    end

    // Reset Behavior
    always @(posedge pclk) begin
        if (preset_n) begin
            reg_out <= 0;
            pready <= 1'b0;
            pslverr <= 1'b0;
            reg_gpio_in <= 1'b0;
            reg_gpio_out <= 1'b0;
            reg_gpio_enable <= 1'b0;
            reg_gpio_int <= 1'b0;
        end
    end

endmodule
