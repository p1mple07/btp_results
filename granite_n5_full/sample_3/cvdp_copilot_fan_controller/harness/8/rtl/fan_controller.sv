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
    reg [7:0] TEMP_LOW ;      // Low temperature threshold
    reg [7:0] TEMP_MED ;      // Medium temperature threshold
    reg [7:0] TEMP_HIGH;      // High temperature threshold
    reg [7:0]  temp_adc_in;   // Temperature sensor input (0-255)
  
    reg setup;
    // APB Protocol States
    always @(posedge clk or posedge reset)
	begin
        if (reset)
        begin
            prdata   <= 8'b0;
            pready   <= 1'b0;
            pslverr  <= 1'b0;
            TEMP_LOW <= 8'd30;
            TEMP_MED <= 8'd60;
            TEMP_HIGH <=8'd90;
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
                end
                else 
                begin
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
    wire [2:0] speed_control;    //speed control bit 
    // Fan speed adjustment logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_duty_cycle <= 8'd0;  // Fan off by default
        end 
        else
        begin
            case(speed_control)
              3'd1 : pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle)
             3'd2 : pwm_duty_cycle <= 8'd128; // Medium speed (50% duty cycle)
            ... (continue with other cases)
            3'd3 : pwm_duty_cycle <= 8'd192; // High speed (75% duty cycle)
            3'd4 : pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
            default : 8'd255; // Full speed (100% duty cycle)
            endcase

            // PWM generation logic
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    pwm_duty_cycle <= 8'd0;
                    fan_pwm_out <= 1'b0;
                end
                else
                begin
                    pwm_counter <= 8'd0;
                    fan_pwm_out <= 1'b0;
                end 
            end
        endmodule