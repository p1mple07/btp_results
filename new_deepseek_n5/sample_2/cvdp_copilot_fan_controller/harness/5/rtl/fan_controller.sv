module fan_controller (
    input wire clk,                 // System clock
    input wire reset,               // Reset signal
    output reg fan_pwm_out,         // PWM output for fan control

    //APB signals
    input wire reset,               // Slave select
    input wire penable,             // Enable signal
    input wire pwrite,              // Write control
    input wire [7:0] paddr,         // Address bus
    input wire [7:0] pwdata,         // Write data bus
    output reg [7:0] prdata,         // Read data bus
    output reg pready,              // Ready signal
    output reg pslverr     // Slave error
);

    // Parameters for temperature thresholds
    reg [7:0] TEMP_LOW ;      // Low temperature threshold
    reg [7:0] TEMP_MED ;      // Medium temperature threshold
    reg [7:0] TEMP_HIGH;      // High temperature threshold
    reg [7:0]  temp_adc_in;   // Temperature sensor input (0-255)

    reg setup;
    // APB Protocol States
    always @(posedge clk or posedge reset) begin
        if (reset)
        begin
            prdata   <= 7'd0;
            pready   <= 1'b0;
            pslverr  <= 1'b0;
            TEMP_LOW <= 7'd30;
            TEMP_MED <= 7'd60;
            TEMP_HIGH <=7'd90;
            setup  <= 1'b0;
        end
        else
        begin
            case(speed_control)
              1 : pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle)
              2 : pwm_duty_cycle <= 8'd128; // Medium speed (50% duty cycle)
              3 : pwm_duty_cycle <= 8'd192; // High speed (75% duty cycle)
              4 : pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
            endcase

            reg setup;
            // APB Error Handling Logic
            if (pwrite)
             begin
                case(paddr)
                      16'h0a: begin 
                          TEMP_LOW <= pwdata;
                          pslverr     <= 1'b0;
                          end
                      16'h0b: begin 
                          TEMP_MED    <= pwdata;
                          pslverr     <= 1'b0;
                          end
                      16'h0c: begin
                          TEMP_HIGH   <= pwdata;
                          pslverr     <= 1'b0;
                          end
                      16'h0f:  begin
                          temp_adc_in <= pwdata;
                          pslverr     <= 1'b0;
                          end
                      default:pslverr  <= 1'b1;
                endcase
            else 
                case(paddr)
                      16'h0a: begin
                          prdata   <= TEMP_LOW ;
                          pslverr  <= 1'b0;
                          end
                      16'h0b: begin 
                          prdata   <= TEMP_MED ;
                          pslverr  <= 1'b0;
                          end
                      16'h0c: begin
                          prdata   <= TEMP_HIGH;
                          pslverr  <= 1'b0;
                          end
                      16'h0f: begin
                          prdata   <= temp_adc_in;
                          pslverr  <= 1'b0;
                          end
                      default:pslverr  <= 1'b1;
                endcase
            end
        end
    end

    // PWM control
    reg [7:0] pwm_duty_cycle;    // Duty cycle (0-255)
    reg [7:0] pwm_counter;       // Counter for PWM generation
    wire [1:0] speed_control;    // Speed control
    // Fan speed adjustment logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_duty_cycle <= 8'd0;
        end else begin
            case(speed_control)
              1 : pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle)
              2 : pwm_duty_cycle <= 8'd128; // Medium speed (50% duty cycle)
              3 : pwm_duty_cycle <= 8'd192; // High speed (75% duty cycle)
              4 : pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
            endcase
        end
    end

    assign speed_control = 0;
    case(temp_adc_in)
        default: speed_control = 0;
        when(7'd0) speed_control = 1;
        when(7'd1) speed_control = 2;
        when(7'd2) speed_control = 3;
    endcase