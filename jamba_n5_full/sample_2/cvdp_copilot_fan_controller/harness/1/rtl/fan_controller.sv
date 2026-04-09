module fan_controller (
    input wire clk,                 // System clock
    input wire reset,               // Reset signal
    output reg fan_pwm_out,         // PWM output for fan control

    // APB interface signals
    input  wire         psel,       // Slave select
    input  wire         penable,    // Enable signal
    input  wire         pwrite,     // Write control
    input  wire [7:0]   paddr,      // Address bus
    input  wire [7:0]   pwdata,     // Write data bus
    output reg  [7:0]   prdata,     // Read data bus
    output reg          pready,      // Ready signal
    output reg          pslverr     // Slave error
);

    // Threshold registers (example values)
    localparam int TEMP_LOW = 8'h0A;
    localparam int TEMP_MED = 8'h0B;
    localparam int TEMP_HIGH = 8'h0C;

    // Internal registers for temperature values
    reg [7:0] temp_low, temp_med, temp_high, temp_adc_in;

    // APB state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp_low <= 0;
            temp_med <= 0;
            temp_high <= 0;
            temp_adc_in <= 0;
            psel_apb <= 0;
            penable_apb <= 0;
            pwrite_apb <= 0;
            paddr_apb <= 8'h00;
            pwdata_apb <= 0;
            prdata_apb <= 0;
            pready <= 0;
            pslverr <= 0;
            fan_pwm_out <= 1'b0;
        end else begin
            case (psel_apb)
                1'b0: begin // Read operation
                    pready <= 0;
                    pslverr <= 0;
                    prdata_apb <= paddr_apb;
                    paddr_apb <= paddr_apb;
                    pwdata_apb <= 0;
                end
                1'b1: begin // Write operation
                    psw_apb <= 1;
                    pen_apb <= 1;
                    paddr_apb <= paddr_apb;
                    pwdata_apb <= pwdata;
                    prdata_apb <= pdata;
                end
            endcase
        end
    end

    // Temperature‑based fan speed control (simple example)
    always @(*) begin
        if (temp_adc_in < TEMP_LOW) begin
            temp_low_val <= 0;
        end else if (temp_adc_in < TEMP_MED) begin
            temp_low_val <= TEMP_LOW;
        end else if (temp_adc_in < TEMP_HIGH) begin
            temp_low_val <= TEMP_MED;
        end else begin
            temp_low_val <= TEMP_HIGH;
        end
    end

endmodule
