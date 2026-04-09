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

    // Parameters for temperature thresholds
    signed [7:0] low_temperature_threshold ;      // Low temperature threshold
    signed [7:0] medium_temperature_threshold ;  // Medium temperature threshold
    signed [7:0] high_temperature_threshold ;   // High temperature threshold
    signed [7:0]  temp_adc_in;   // Temperature sensor input (0-255)
  
    reg setup;
    // APB Protocol States
    always @(posedge clk or posedge reset)
	begin
        if (reset)
        begin
            prdata   <= 7'b0;
            pready   <= 1'b0;
            pslverr  <= 1'b0;
            low_temperature_threshold <= 7'd30;
            medium_temperature_threshold <= 7'd60;
            high_temperature_threshold <=7'd90;
            setup  <= 1'b0;
        end
        else
        begin
            if (psel &&!penable &&!setup)
            begin
                // Setup phase: Indicate the slave is not yet ready
                pready <= 1'b0;
                setup  <= 1'b1;

            end
            else if (psel && penable && setup)
            begin
                // Access phase: Perform read/write operation and indicate ready
                pready <= 1'b1; // Slave is ready for the current operation
                setup  <= 1'b0;
                if (pwrite)
                 begin
                    // Write Operation
                    case(paddr)
                         16'h0a: begin 
                                  low_temperature_threshold    <= pwdata;
                                  pslverr                     <= 1'b0;
                                  end
                         16'h0b: begin 
                                  medium_temperature_threshold <= pwdata;
                                  pslverr                     <= 1'b0;
                                  end
                         16'h0c: begin
                                  high_temperature_threshold    <= pwdata;
                                  pslverr                     <= 1'b0;
                                  end
                         16'h0f: begin
                                  temp_adc_in <= pwdata;
                                  pslverr                     <= 1'b0;
                                  end
                          default:pslverr     <= 1'b1;
                    endcase
                end
                else 
                begin
                    // Read Operation
                    case(paddr)
                         16'h0a: begin
                                  prdata   <= low_temperature_threshold;
                                  pslverr  <= 1'b0;
                                  end
                         16'h0b: begin 
                                  prdata   <= medium_temperature_threshold;
                                  pslverr  <= 1'b0;
                                  end
                         16'h0c: begin
                                  prdata   <= high_temperature_threshold;
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
            else
            begin
                // Default case: Clear ready signal when not selected
                pready <= 1'b0;
                setup  <= 1'b0;
            end
        end
    end

    // PWM control
    reg [7:0] pwm_duty_cycle;    // Duty cycle (0-255)
    reg [7:0] pwm_counter;       // Counter for PWM generation
    reg [1:0] speed_control;    // Speed control bit 
    // Fan speed adjustment logic
    always @(posedge clk or posedge reset) begin
        if (reset)
        begin
            pwm_counter <= 8'd0;  // Fan off by default
        end
        else
        begin
            case(speed_control)
              1 : pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle
              2 : 8'd128;     // Medium speed (50% duty cycle
              3 : 8'd192;  // High speed (75% duty cycle
              4 : 8'd255;    // Full speed (100% duty cycle
 
             // Fan speed adjustment logic
             always @(posedge clk or posedge reset) begin
                if (reset) begin
                   // Add code to adjust fan speed based on temperature.
                    pwm_counter <= 8'd0;
                    speed_control <= 1'b1; 
                end
             end
         
         // Add code to check for low temperature during normal operation of the code.
    }
}