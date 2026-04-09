module fan_controller (
    input wire clk,                 // System clock
    input wire reset,               // Reset signal
    output reg fan_pwm_out,         // PWM output for fan control

    // APB signals
    input  wire         psel,       // Slave select
    input  wire         penable,    // Enable signal
    input  wire         pwrite,     // Write control
    input  wire [7:0]   paddr,      // Address bus
    input  wire [7:0]   pwdata,     // Write data bus
    output reg  [7:0]   prdata,     // Read data bus
    output reg          pready,      // Ready signal
    output reg          pslverr     // Slave error
);

    // Parameters for temperature thresholds
    reg [7:0] TEMP_LOW  = 8'd30;
    reg [7:0] TEMP_MED  = 8'd60;
    reg [7:0] TEMP_HIGH = 8'd90;
    reg [7:0]  temp_adc_in;

    reg setup;
    always @(posedge clk or posedge reset) begin
        if (reset)
            begin
                prdata   <= 8'b0;
                pready   <= 1'b0;
                pslverr  <= 1'b0;
                TEMP_LOW <= 8'd30;
                TEMP_MED <= 8'd60;
                TEMP_HIGH <=8'd90;
                setup      <= 1'b0;
            end
        else
        begin
            if (psel && penable && setup)
            begin
                // Access phase
                pready <= 1'b1;
                setup  <= 1'b0;
                if (pwrite)
                    case(paddr)
                        8'h0a: begin
                                  TEMP_LOW    <= pwdata;
                                  pslverr     <= 1'b0;
                                  end
                        8'h0b: begin
                                  TEMP_MED    <= pwdata;
                                  pslverr     <= 1'b0;
                                  end
                        8'h0c: begin
                                  TEMP_HIGH   <= pwdata;
                                  pslverr     <= 1'b0;
                                  end
                        8'h0f: begin
                                  temp_adc_in <= pwdata;
                                  pslverr     <= 1'b0;
                                  end
                        default:pslverr     <= 1'b1;
                    endcase
                else
                    // Read Operation
                    case(paddr)
                        8'h0a: begin
                                  prdata   <= TEMP_LOW ;
                                  pslverr  <= 1'b0;
                                  end
                        8'h0b: begin 
                                  prdata   <= TEMP_MED ;
                                  pslverr  <= 1'b0;
                                  end
                        8'h0c: begin
                                  prdata   <= TEMP_HIGH;
                                  pslverr  <= 1'b0;
                                  end
                        8'h0f: begin
                                  prdata   <= temp_adc_in;
                                  pslverr  <= 1'b0;
                                  end
                    endcase
            end
            else
            begin
                // Default case
                pready <= 1'b0;
                setup  <= 1'b0;
            end
        end
    end

    // PWM control
    reg [7:0] pwm_duty_cycle;
    wire [2:0] speed_control;

    always @(posedge clk or posedge reset) begin
        if (reset)
        begin
            pwm_duty_cycle <= 8'd0;
        end
        else
        begin
            case(speed_control)
                3'd1: pwm_duty_cycle <= 8'd64;
                3'd2: pwm_duty_cycle <= 8'd128;
                3'd3: pwm_duty_cycle <= 8'd192;
                3'd4: pwm_duty_cycle <= 8'd255;
            default: pwm_duty_cycle <= 8'd255;
            endcase

            // Determine fan speed based on ADC reading
            speed_control = (temp_adc_in < TEMP_LOW ? 3'd1 :
                             (temp_adc_in < TEMP_MED ? 3'd2 :
                              (temp_adc_in < TEMP_HIGH ? 3'd3 : 3'd4)));
        end

        // Generate PWM signal
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                pwm_counter <= 8'd0;
                fan_pwm_out <= 1'b0;
            end
            else
            begin
                pwm_counter <= pwm_counter + 1;
                fan_pwm_out <= (pwm_counter < pwm_duty_cycle) ? 1'b1 : 1'b0;
            end
        end
    end

endmodule
