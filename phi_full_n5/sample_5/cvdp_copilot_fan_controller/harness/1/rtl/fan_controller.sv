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
);

    // Internal registers
    reg [7:0] temp_low, temp_med, temp_high, temp_adc_in;

    // State variables
    reg [3:0] state, prev_state;
    reg [7:0] pwm_duty_cycle;

    // Always block for clocked processes
    always @(posedge clk) begin
        if (reset) begin
            state <= 4'b0000;
            temp_low <= 8'h00;
            temp_med <= 8'h00;
            temp_high <= 8'h00;
            temp_adc_in <= 8'h00;
            pwm_duty_cycle <= 8'h00;
        end else begin
            if (psel) begin
                state <= prev_state;
            end

            case (state)
                4'b0000: begin // Setup Phase
                    if (pwrite) begin
                        if (paddr == 8'h0a) temp_low <= pwdata;
                        else if (paddr == 8'h0b) temp_med <= pwdata;
                        else if (paddr == 8'h0c) temp_high <= pwdata;
                        else pslverr <= 1'b1;
                    end
                    penable <= 1'b1;
                end
                4'b0001: begin // Access Phase
                    pready <= 1'b1;
                    if (paddr == 8'h0a) temp_low <= temp_low;
                    else if (paddr == 8'h0b) temp_med <= temp_med;
                    else if (paddr == 8'h0c) temp_high <= temp_high;
                    else pslverr <= 1'b1;

                    // Determine PWM duty cycle
                    case (temp_adc_in)
                        8'h00: pwm_duty_cycle <= 8'h06;
                        8'h80: pwm_duty_cycle <= 8'h88;
                        8'h40: pwm_duty_cycle <= 8'h7c;
                        default: pwm_duty_cycle <= 8'h00;
                    endcase
                end
                prev_state <= state;
            end
        end
    end

    // PWM Generation
    always @(posedge clk) begin
        if (pready) begin
            fan_pwm_out <= pwm_duty_cycle;
        end
    end

    // Error Handling
    always @(*) begin
        if (pslverr) pwm_duty_cycle <= 8'h00;
    end

endmodule
