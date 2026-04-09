module fan_controller (
    input wire clk,                 // System clock
    input wire reset,               // Reset signal
    output reg fan_pwm_out,         // PWM output for fan control

    //APB signals
    input  wire         psel,       // Slave select
    input  wire         penable,    // Enable signal
    input  wire         pwrite,     // Write control
    input  wire [7:0]   paddr,      // Address bus
    input  wire [7:0]   pwdata,     // Write data bus
    output reg  [7:0]   prdata,     // Read data bus
    output reg          pready,      // Ready signal
    output reg          pslverr     // Slave error
)
// State: 0 = idle, 1 = setup, 2 = access
reg state = 0;
reg temp_reg = 0;
reg [7:0] desired_duty_reg = 0;

always @posedge clk begin
    if (reset) begin
        state = 0;
        temp_reg = 0;
        desired_duty_reg = 0;
        prdata = 0;
        pready = 0;
        pslverr = 0;
        // Wait for APB master to select
        wait until psel;
    end else if (psel && !penable) begin
        // Setup phase: decode address
        state = 1;
        case (paddr)
            0x0a: temp_reg = TEMP_LOW;
            0x0b: temp_reg = TEMP_MED;
            0x0c: temp_reg = TEMP_HIGH;
            0x0f: temp_reg = temp_adc_in;
            default: begin
                pslverr = 1;
                state = 2;
                end
        endcase
    end else if (psel && penable) begin
        // Access phase
        state = 2;
        if (pwrite) begin
            // Write operation
            case (paddr)
                0x0a: TEMP_LOW = pwdata;
                0x0b: TEMP_MED = pwdata;
                0x0c: TEMP_HIGH = pwdata;
                0x0f: temp_adc_in = pwdata;
                default: begin
                    pslverr = 1;
                    state = 0;
                    end
            endcase
        else begin
            // Read operation
            prdata = temp_reg;
            state = 0;
        end
    end
end

// Determine duty cycle based on temperature
always @posedge clk begin
    case (temp_adc_in)
        8: desired_duty_reg = 64;
        16: desired_duty_reg = 128;
        24: desired_duty_reg = 192;
        32: desired_duty_reg = 255;
        default: desired_duty_reg = 0;
    endcase
end

// PWM control
always @posedgeclk begin
    if (state == 2) begin
        if (desired_duty_reg) begin
            fan_pwm_out = 1;
            prdata = desired_duty_reg;
        else
            fan_pwm_out = 0;
            prdata = 0;
        end
    end
end

endmodule