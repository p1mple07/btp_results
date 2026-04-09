module cvdp_copilot_apb_gpio (
    input logic pclk,
    input logic preset_n,
    input logic psel,
    input logic [7:0] paddr[7:0],
    input logic penable,
    input logic [31:0] pwrite,
    input logic [31:0] pwdata[31:0],
    input logic [31:0] gpio_in[GPIO_WIDTH-1:0],
    output logic [31:0] prdata[31:0],
    output logic [31:0] pslverr,
    output logic [31:0] gpio_out[GPIO_WIDTH-1:0],
    output logic [31:0] gpio_enable[GPIO_WIDTH-1:0],
    output logic [31:0] gpio_int[GPIO_WIDTH-1:0],
    output logic comb_int
);

    localparam num_gpios = gpio_width;
    reg [31:0] reg_output;
    reg [31:0] reg_input;
    reg [7:0] reg_enable_value;
    reg [7:0] reg_direction_value;
    reg [7:0] reg_interrupt_en;
    reg [7:0] reg_polarity_value;
    reg [7:0] reg_state_value;

    always @(posedge pclk) begin
        if (!preset_n) begin
            prdata[31:0] <= 32'h0;
            pslverr <= 1'b0;
            gpio_out[GPIO_WIDTH-1:0] <= 32'h0;
            gpio_enable[GPIO_WIDTH-1:0] <= 32'h0;
            gpio_int[GPIO_WIDTH-1:0] <= 32'h0;
            comb_int <= 32'h0;
        end else begin
            reg_input <= paddr[7:2];
            reg_output <= pwrdata[7:0];
            reg_enable_value <= pwrite;
            reg_direction_value <= psel;
            reg_interrupt_en <= psel;
            reg_polarity_value <= psel;
            reg_state_value <= psel;
        end
    end

    assign prdata = reg_output;
    assign pslverr = 1'b0;
    assign gpio_out = reg_output;
    assign gpio_enable = reg_enable_value;
    assign gpio_int = reg_interrupt_en;
    assign comb_int = reg_state_value;

endmodule
