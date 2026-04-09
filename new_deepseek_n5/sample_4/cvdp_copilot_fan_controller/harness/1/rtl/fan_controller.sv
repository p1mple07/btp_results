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
// State variables
    register  wire [1:0] state;     // 0=setup, 1=access
    register  wire [7:0]  temp_reg; // Temperature register (0x0a-0x0f)
    register  wire [7:0]  result;    // Result of operation
    register  wire [8:0]  counter;   // PWM counter

// FIFO buffer for AMBA communication
    fifo_tap_tap FIFO( .rst(0), .clk(clk), .taps_out(prdata), .taps_in(pwdata) );

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset all registers and clear outputs
        $clear fan_pwm_out;
        state = 0;
        pready = 0;
        pslverr = 0;
        temp_reg = 0;
        result = 0;
        counter = 0;
    end else begin
        case (state)
            0: // Setup phase
                if (penable) begin
                    // Decode address
                    temp_reg = paddr;
                    state = 1;
                    pready = 1;
                end
            1: // Access phase
                if (pwrite) begin
                    // Perform read/write operation
                    if (pwrite) begin
                        // Read operation
                        result = temp_reg;
                        temp_reg = 0;
                        pready = 1;
                    end else begin
                        // Write operation
                        temp_reg = pwdata;
                        pready = 1;
                    end
                end
                // Update state
                state = 0;
        end
    end
end

// Temperature-based fan control
always_ff @(posedgeclk) begin
    case (temp_reg)
        0x0a: begin
            result = TEMP_LOW;
            pready = 1;
        end
        0x0b: begin
            result = TEMP_MED;
            pready = 1;
        end
        0x0c: begin
            result = TEMP_HIGH;
            pready = 1;
        end
        else: begin
            result = temp_adc_in;
            pready = 1;
        end
    end
end

// PWM signal generation
always_ff @(posedgeclk) begin
    case (state)
        1: begin
            case (result)
                TEMP_LOW: counter = 64;
                TEMP_MED: counter = 128;
                TEMP_HIGH: counter = 192;
                default: counter = 255;
            endcase
            pready = 1;
        end
    end
end

// Error handling
always_ff @(posedgeclk) begin
    if (paddr < 0x0a || paddr > 0x0f) begin
        pslverr = 1;
        pready = 0;
    end else if (pwdata > 0xFF || pwdata < 0x00) begin
        pslverr = 1;
        pready = 0;
    end
end