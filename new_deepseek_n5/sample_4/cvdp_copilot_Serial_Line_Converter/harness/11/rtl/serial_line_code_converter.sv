module serial_line_code_converter #(parameter CLK_DIV = 16),
    (parameter [4:0] mode)  // 5-bit mode selector including error detection
    (input  logic clk,             // System clock
     input  logic reset_n,         // Active-low reset
     input  logic enable,          // Enable signal
     input  logic serial_in,       // Serial input signal
     input  logic [2:0] mode)      // Mode selector
    (output logic serial_out       // Serial output signal
     , output [15:0] diagnostic_bus)  // Diagnostic output bus
     , output logic error_flag      // Error flag output
     , output logic error_counter); // Error counter output

    // Internal signals
    logic [3:0]clk_counter;      // Clock divider counter
    logicclk_pulse;              // Clock pulse for sampling
    logic prev_serial_in;         // Previous serial input for edge detection
    logic prev_value;             // Holds the previous value of serial_in
    logic nrz_out;                // NRZ encoding output
    logic rz_out;                 // Return-to-Zero encoding output
    logic diff_out;               // Differential encoding output
    logic inv_nrz_out;            // Inverted NRZ output
    logic alt_invert_out;         // NRZ with alternating bit inversion output
    logic alt_invert_state;       // State for alternating inversion
    logic parity_out;             // Parity Bit Output
    logic scrambled_out;          // Scrambled NRZ output
    logic edge_triggered_out;     // Edge-Triggered NRZ output
    logic [4:0] error_code;       // Error code output
    logic [15:0] diagnostic_bus;  //Diagnostic output bus

    // Internal registers
    reg [7:0] error_counter;     // 8-bit error counter
    reg error_flag;              // Error flag

    // Internal signals for diagnostic bus
    logic [3:0] clock_pulse_state; // Clock pulse status
    logic encoded_output;         // Encoded output
    logic alt_invert_state;       // Alternating inversion state
    logic parity_bit;             // Parity bit

    // Internal signals for error detection
    logic invalid_serial_in;     // Flag for invalid serial_in
    logic [15:0] diagnostic_bits; // Diagnostic output bus

    // Internal signals for error detection
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            clk_pulse <= 0;
            prev_value <= 0;
            prev_serial_in <= 0;
            invalid_serial_in <= 0;
            error_flag <= 0;
            error_counter <= 0;
        end else begin
            prev_value <= serial_in;
            prev_serial_in <= prev_value;
            invalid_serial_in <= 0;
            error_flag <= 0;
            error_counter <= 0;
        end
    end

    // Always blocks
    always_comb begin
        case (mode)
            5'b00000: serial_out = nrz_out;
                        error_code = 5'b00000;
                        clock_pulse_state = 0;
                        encoded_output = nrz_out;
                        alt_invert_state = 0;
                        parity_bit = 0;
                        invalid_serial_in = 0;
            5'b00001: serial_out = rz_out;
                        error_code = 5'b00001;
                        clock_pulse_state = 0;
                        encoded_output = rz_out;
                        alt_invert_state = 0;
                        parity_bit = 0;
                        invalid_serial_in = 0;
            5'b00010: serial_out = diff_out;
                        error_code = 5'b00010;
                        clock_pulse_state = 0;
                        encoded_output = diff_out;
                        alt_invert_state = 0;
                        parity_bit = 0;
                        invalid_serial_in = 0;
            5'b00011: serial_out = inv_nrz_out;
                        error_code = 5'b00011;
                        clock_pulse_state = 0;
                        encoded_output = inv_nrz_out;
                        alt_invert_state = 0;
                        parity_bit = 0;
                        invalid_serial_in = 0;
            5'b00100: serial_out = alt_invert_out;
                        error_code = 5'b00100;
                        clock_pulse_state = 0;
                        encoded_output = alt_invert_out;
                        alt_invert_state = 1;
                        parity_bit = 0;
                        invalid_serial_in = 0;
            5'b00101: serial_out = parity_out;
                        error_code = 5'b00101;
                        clock_pulse_state = 0;
                        encoded_output = parity_out;
                        alt_invert_state = 0;
                        parity_bit = 1;
                        invalid_serial_in = 0;
            5'b00110: serial_out = scrambled_out;
                        error_code = 5'b00110;
                        clock_pulse_state = 0;
                        encoded_output = scrambled_out;
                        alt_invert_state = 0;
                        parity_bit = 0;
                        invalid_serial_in = 0;
            5'b00111: serial_out = edge_triggered_out;
                        error_code = 5'b00111;
                        clock_pulse_state = 0;
                        encoded_output = edge_triggered_out;
                        alt_invert_state = 0;
                        parity_bit = 0;
                        invalid_serial_in = 0;
            default: serial_out = 0;
                        error_flag = 0;
                        error_counter = 0;
                        invalid_serial_in = 0;
        endcase
    end

    // Error detection logic
    always_comb begin
        if (invalid_serial_in) begin
            error_flag <= 1;
            error_counter <= error_counter + 1;
        end
    end

    // Diagnostic bus assignment
    always_comb begin
        diagnostic_bus[15:13] = mode;
        diagnostic_bus[12] = error_flag;
        diagnostic_bus[11:4] = error_counter;
        diagnostic_bus[3] = clock_pulse_state;
        diagnostic_bus[2] = encoded_output;
        diagnostic_bus[1] = alt_invert_state;
        diagnostic_bus[0] = parity_bit;
    end

    // Enable control
    always_comb begin
        if (enable) begin
            // All logic remains the same when enable is high
        end else begin
            // Reset all outputs to 0 when enable is low
            serial_out <= 0;
            error_flag <= 0;
            error_counter <= 0;
            invalid_serial_in <= 0;
        end
    end