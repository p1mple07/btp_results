module serial_line_code_converter #(parameter CLK_DIV = 16),
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low reset
    input  logic enable,           // Enable signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out,       // Serial output signal
    output logic error_flag,        // Error detection flag
    output logic [15:0] diagnostic_bus  // Diagnostic output bus
);

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
    logic [7:0] error_counter;    // 8-bit error counter

    // Internal registers
    register logic prev_serial_in;
    register logic prev_value;

    // Always combinational section
    always_comb begin
        case (mode)
            3'b000: serial_out = nrz_out;
            3'b001: serial_out = rz_out;
            3'b010: serial_out = diff_out;
            3'b011: serial_out = inv_nrz_out;
            3'b100: serial_out = alt_invert_out;
            3'b101: serial_out = parity_out;
            3'b110: serial_out = scrambled_out;
            3'b111: serial_out = edge_triggered_out;
            default: serial_out = 0;
        endcase

        // Error detection and diagnostic output
        if (enable) begin
            diagnostic_bus = [
                (mode << 12),
                (error_flag << 11),
                (error_counter << 10),
                (clk_pulse << 9),
                (serial_out << 8),
                (rz_out << 7),
                (diff_out << 6),
                (inv_nrz_out << 5),
                (alt_invert_out << 4),
                (parity_out << 3),
                (scrambled_out << 2),
                (edge_triggered_out << 1),
                (0) // LSB
            ];
        else begin
            diagnostic_bus = 0;
        end
    end

    // Always synchronous functions
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            clk_pulse <= 0;
            prev_value <= 0;
            prev_serial_in <= 0;
            error_counter <= 0;
        end else begin
            prev_value <= serial_in;
            prev_serial_in <= prev_value;
            prev_value <= serial_in;
            prev_serial_in <= prev_value;
            error_counter <= 0;
        end
    end

    // Always combinational functions
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else begin
            nrz_out <= serial_in;
        end
    end

    always_ff @(posedgeclk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            rz_out <= serial_in & clk_pulse;
        end
    end

    always_ff @(posedgeclk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else begin
            diff_out <= serial_in ^ prev_serial_in;
        end
    end

    always_ff @(posedgeclk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else begin
            inv_nrz_out <= ~serial_in;
        end
    end

    always_ff @(posedgeclk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out <= 0;
            alt_invert_state <= 0;
        end else begin
            alt_invert_state <= ~alt_invert_state;
            alt_invert_out <= alt_invert_state ? ~serial_in : serial_in;
        end
    end

    always_ff @(posedgeclk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else begin
            parity_out <= serial_in ^ parity_out;
        end
    end

    always_ff @(posedgeclk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else begin
            scrambled_out <= serial_in ^ (clk_counter[0] ^ 1);
        end
    end

    always_ff @(posedgeclk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end