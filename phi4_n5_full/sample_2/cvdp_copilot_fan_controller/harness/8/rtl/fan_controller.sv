module fan_controller (
    input wire clk,                 
    input wire reset,               
    output reg fan_pwm_out,         

    // APB signals
    input  wire         psel,       
    input  wire         penable,    
    input  wire         pwrite,     
    input  wire [7:0]   paddr,      
    input  wire [7:0]   pwdata,     
    output reg  [7:0]   prdata,     
    output reg          pready,     
    output reg          pslverr     
);

    // Parameters for temperature thresholds
    reg [7:0] TEMP_LOW ;      
    reg [7:0] TEMP_MED ;      
    reg [7:0] TEMP_HIGH;      
    reg [7:0] temp_adc_in;   

    reg setup;

    // APB Protocol State Machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prdata   <= 8'b0;
            pready   <= 1'b0;
            pslverr  <= 1'b0;
            TEMP_LOW <= 8'd30;
            TEMP_MED <= 8'd60;
            TEMP_HIGH<=8'd90;
            setup    <= 1'b0;
        end else begin
            if (psel && !penable && !setup) begin
                pready <= 1'b0;
                setup  <= 1'b1;
            end else if (psel && penable && setup) begin
                pready <= 1'b1;  // Indicate slave ready for current operation
                setup  <= 1'b0;
                if (pwrite) begin
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
                        default: pslverr     <= 1'b1;
                    endcase
                end else begin
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
                        default: pslverr  <= 1'b1;
                    endcase
                end
            end else begin
                // Default case: Clear ready signal when not selected
                pready <= 1'b0;
                setup  <= 1'b0;
            end
        end
    end

    // PWM Control: Combine combinational duty cycle calculation into one always block,
    // eliminating the intermediate "speed_control" wire for area optimization.
    reg [7:0] pwm_duty_cycle;    // Duty cycle (0-255)
    reg [7:0] pwm_counter;       // Counter for PWM generation

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_duty_cycle <= 8'd0;
        end else begin
            // Directly compute duty cycle based on temperature thresholds.
            if (temp_adc_in < TEMP_LOW)
                pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle)
            else if (temp_adc_in < TEMP_MED)
                pwm_duty_cycle <= 8'd128; // Medium speed (50% duty cycle)
            else if (temp_adc_in < TEMP_HIGH)
                pwm_duty_cycle <= 8'd192; // High speed (75% duty cycle)
            else
                pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
        end
    end

    // PWM Generation Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_counter  <= 8'd0;
            fan_pwm_out  <= 1'b0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            fan_pwm_out <= (pwm_counter < pwm_duty_cycle) ? 1'b1 : 1'b0;
        end
    end

endmodule