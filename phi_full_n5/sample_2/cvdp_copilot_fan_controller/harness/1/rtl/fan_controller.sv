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
    reg [7:0] TEMP_LOW, TEMP_MED, TEMP_HIGH;
    reg temp_adc_in;
    reg [7:0] fan_pwm_duty_cycle;

    // State machine variables
    reg [1:0] state, next_state;
    reg [3:0] counter;

    // Always block for state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 2'b00; // Initial state
            fan_pwm_duty_cycle <= 8'd0; // Initial duty cycle
            counter <= 4'd0;
            pready <= 1'b0;
            pslverr <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    // State transition logic
    always @(state or pwrite or paddr) begin
        case (state)
            2'b00: begin
                if (psel) begin
                    // Setup phase
                    next_state <= 2'b01;
                end else begin
                    next_state <= 2'b00;
                end
            end
            2'b01: begin
                if (penable) begin
                    // Access phase
                    if (pwrite) begin
                        case (paddr)
                            8'h0a: TEMP_LOW <= pwdata;
                            8'h0b: TEMP_MED <= pwdata;
                            8'h0c: TEMP_HIGH <= pwdata;
                            8'h0f: temp_adc_in <= pwdata;
                            default: pslverr <= 1'b1;
                        endcase
                        prdata <= temp_adc_in;
                        pready <= 1'b1;
                    end else if (paddr) begin
                        prdata <= TEMP_LOW;
                        pready <= 1'b1;
                    end else begin
                        pslverr <= 1'b1;
                    end
                    next_state <= 2'b10;
                end else begin
                    next_state <= 2'b01;
                end
            end
            2'b10: begin
                case (temp_adc_in)
                    8'h00: begin
                        fan_pwm_duty_cycle <= 8'd64;
                        counter <= 4'd0;
                    end
                    8'h01: begin
                        fan_pwm_duty_cycle <= 8'd128;
                        counter <= 4'd0;
                    end
                    8'h02: begin
                        fan_pwm_duty_cycle <= 8'd192;
                        counter <= 4'd0;
                    end
                    8'h03: begin
                        fan_pwm_duty_cycle <= 8'd255;
                        counter <= 4'd0;
                    end
                    default: pslverr <= 1'b1;
                end
                if (counter == fan_pwm_duty_cycle) begin
                    fan_pwm_out <= 1'b1;
                    counter <= 4'd0;
                end else begin
                    fan_pwm_out <= 1'b0;
                    counter <= counter + 1'b1;
                end
                next_state <= 2'b00;
            end
        end
    end

    // PWM output generation
    always @(posedge clk) begin
        if (state == 2'b10) begin
            fan_pwm_out <= fan_pwm_duty_cycle;
        end
    end

    // Reset behavior
    always @(posedge clk) begin
        if (reset) begin
            state <= 2'b00;
            fan_pwm_duty_cycle <= 8'd0;
            counter <= 4'd0;
            pready <= 1'b0;
            pslverr <= 1'b0;
        end
    end

endmodule
