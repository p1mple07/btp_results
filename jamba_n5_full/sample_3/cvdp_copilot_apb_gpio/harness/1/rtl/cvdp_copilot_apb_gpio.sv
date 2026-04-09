module cvdp_copilot_apb_gpio #(
    parameter INT_WIDTH = 8,
    parameter CLK_RISE = 1,
    parameter RESET_ACTIVE = 0 // 0 for active low, 1 for active high
)(
    input logic pclk,
    input logic preset_n,
    input logic psel,
    input logic [7:0] paddr[7:0],
    input logic penable,
    input logic [31:0] pwrite,
    input logic [31:0] pwdata[31:0],
    input logic [GPIO_WIDTH-1:0] gpio_in[GPIO_WIDTH-1:0],

    output logic [31:0] prdata[31:0],
    output logic [31:0] pslverr,
    output logic [31:0] gpio_out[GPIO_WIDTH-1:0],
    output logic gpio_enable[GPIO_WIDTH-1:0],
    output logic gpio_int[GPIO_WIDTH-1:0],
    output logic comb_int,

    input logic clk,
    input logic rst_n
);

    localparam int CLK_PERIOD = 1 / $display("%f", $timeformat);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prdata[31:0] <= 0;
            pslverr <= 0;
            gpio_out[0:0] <= 0;
            gpio_enable[0:0] <= 1;
            gpio_int[0:0] <= 0;
            comb_int <= 0;
        end else begin
            if (preset_n) begin
                prdata[31:0] <= 0;
                pslverr <= 0;
                gpio_out[0:0] <= 0;
                gpio_enable[0:0] <= 1;
                gpio_int[0:0] <= 0;
                comb_int <= 0;
            end else begin
                // Sync gpio_in with reset
                if (rst_n) begin
                    gpio_in[0:0] <= 0;
                end else begin
                    // Two-stage flip-flop for metastability
                    assign gpio_in[0:0] = ~gpio_in[0:0];
                    assign gpio_in[0:0] = gpio_in[0:0];
                end
                // Read output data
                assign prdata = gpio_out;
            end
        end
    end

    // APB control logic
    always @(posedge pclk) begin
        if (penable) begin
            assign pslverr = 1;
            // Write operation
            assign pwrite = gpio_in[0:0];
            assign pslverr = 0;
        end else begin
            assign pwrdata = 0;
        end
    end

    // Read operation
    always @(posedge pclk) begin
        if (!pready) begin
            assign prdata = 0;
        end else begin
            assign prdata = pwrdata;
        end
    end

    // Generate interrupts
    always @(*) begin
        comb_int = 0;
        if (penable && pwrdata[3:0] != 0) begin
            comb_int = comb_int + 1;
        end
        if (pwrite && pwrdata[3:0] == pwrite) begin
            comb_int = comb_int + 1;
        end
    end

    // Interrupt handling
    assign gpio_out[0:0] = gpio_enable[0] && gpio_int[0];
    assign gpio_out[1:1] = gpio_enable[1] && gpio_int[1];
    assign gpio_out[2:2] = gpio_enable[2] && gpio_int[2];
    assign gpio_out[3:3] = gpio_enable[3] && gpio_int[3];
    assign gpio_out[4:4] = gpio_enable[4] && gpio_int[4];
    assign gpio_out[5:5] = gpio_enable[5] && gpio_int[5];
    assign gpio_out[6:6] = gpio_enable[6] && gpio_int[6];
    assign gpio_out[7:7] = gpio_enable[7] && gpio_int[7];
    assign gpio_out[8:8] = gpio_enable[8] && gpio_int[8];
    assign gpio_out[9:9] = gpio_enable[9] && gpio_int[9];
    assign gpio_out[10:10] = gpio_enable[10] && gpio_int[10];
    assign gpio_out[11:11] = gpio_enable[11] && gpio_int[11];
    assign gpio_out[12:12] = gpio_enable[12] && gpio_int[12];
    assign gpio_out[13:13] = gpio_enable[13] && gpio_int[13];
    assign gpio_out[14:14] = gpio_enable[14] && gpio_int[14];
    assign gpio_out[15:15] = gpio_enable[15] && gpio_int[15];

    assign gpio_enable[0:0] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[1:1] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[2:2] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[3:3] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[4:4] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[5:5] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[6:6] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[7:7] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[8:8] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[9:9] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[10:10] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[11:11] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[12:12] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[13:13] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[14:14] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;
    assign gpio_enable[15:15] = (penable && pwrdata[3:0] == pwrite) ? 1 : 0;

    assign gpio_int[0:0] = gpio_in[0] ^ gpio_enable[0];
    assign gpio_int[1:1] = gpio_in[1] ^ gpio_enable[1];
    assign gpio_int[2:2] = gpio_in[2] ^ gpio_enable[2];
    assign gpio_int[3:3] = gpio_in[3] ^ gpio_enable[3];
    assign gpio_int[4:4] = gpio_in[4] ^ gpio_enable[4];
    assign gpio_int[5:5] = gpio_in[5] ^ gpio_enable[5];
    assign gpio_int[6:6] = gpio_in[6] ^ gpio_enable[6];
    assign gpio_int[7:7] = gpio_in[7] ^ gpio_enable[7];
    assign gpio_int[8:8] = gpio_in[8] ^ gpio_enable[8];
    assign gpio_int[9:9] = gpio_in[9] ^ gpio_enable[9];
    assign gpio_int[10:10] = gpio_in[10] ^ gpio_enable[10];
    assign gpio_int[11:11] = gpio_in[11] ^ gpio_enable[11];
    assign gpio_int[12:12] = gpio_in[12] ^ gpio_enable[12];
    assign gpio_int[13:13] = gpio_in[13] ^ gpio_enable[13];
    assign gpio_int[14:14] = gpio_in[14] ^ gpio_enable[14];
    assign gpio_int[15:15] = gpio_in[15] ^ gpio_enable[15];

    assign comb_int = ~comb_int;

endmodule
