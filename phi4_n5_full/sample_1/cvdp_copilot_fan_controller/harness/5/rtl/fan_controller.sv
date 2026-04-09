module fan_controller (
    input wire clk,                 
    input wire reset,               
    output reg fan_pwm_out,         
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
    reg [7:0]  temp_adc_in;   

    reg setup;
    // APB Protocol States
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            prdata   <= 8'b0;         // Fixed: 8-bit constant instead of 7-bit
            pready   <= 1'b0;
            pslverr  <= 1'b0;
            TEMP_LOW <= 8'd30;        // Fixed: 8-bit constant instead of 7-bit
            TEMP_MED <= 8'd60;        // Fixed: 8-bit constant instead of 7-bit
            TEMP_HIGH<= 8'd90;        // Fixed: 8-bit constant instead of 7-bit
            setup    <= 1'b0;
        end
        else
        begin
            if (psel && !penable && !setup)
            begin
                pready <= 1'b0;
                setup  <= 1'b1;
            end
            else if (psel && penable && setup)
            begin
                pready <= 1'b1;
                setup  <= 1'b0;
                if (pwrite)
                begin
                    case(paddr)
                        16'h0a: begin 
                            TEMP_LOW    <= pwdata;
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
                        16'h0f: begin
                            temp_adc_in <= pwdata;
                            pslverr     <= 1'b0;
                        end
                        default: pslverr <= 1'b1;
                    endcase
                end
                else 
                begin
                    case(paddr)
                        16'h0a: begin
                            prdata   <= TEMP_LOW;
                            pslverr  <= 1'b0;
                        end
                        16'h0b: begin 
                            prdata   <= TEMP_MED;
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
                        default: pslverr  <= 1'b1;
                    endcase
                end
            end
            else
            begin
                pready <= 1'b0;
                setup  <= 1'b0;
            end
        end
    end

    // PWM control
    reg [7:0] pwm_duty_cycle;    
    reg [7:0] pwm_counter;       
    // Changed from wire [1:0] to wire [2:0] so that values 1,2,3,4 can be represented.
    wire [2:0] speed_control;    
    // Fan speed adjustment logic
    always @(posedge clk or posedge reset) begin
        if (reset)
        begin
            pwm_duty_cycle <= 8'd0;
        end 
        else
        begin
            case(speed_control)
              3'b001: pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle)
              3'b010: pwm_duty_cycle <= 8'd128; // Medium speed (50% duty cycle)
              3'b011: pwm_duty_cycle <= 8'd192; // High speed (75% duty cycle)
              3'b100: pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
              default: pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
            endcase
        end
    end

    // Fixed the assignment for speed_control by using 3-bit constants to represent values 1,2,3,4.
    assign speed_control = (temp_adc_in < TEMP_LOW ? 3'b001 : 
                           (temp_adc_in < TEMP_MED ? 3'b010 : 
                           (temp_adc_in < TEMP_HIGH ? 3'b011 : 3'b100)));

    // PWM generation logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_counter <= 8'd0;
            fan_pwm_out <= 1'b0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            fan_pwm_out <= (pwm_counter < pwm_duty_cycle) ? 1'b1 : 1'b0;
        end
    end

endmodule