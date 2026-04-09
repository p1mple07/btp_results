module serial_line_code_converter #(parameter CLK_DIV = 16),
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low reset
    input  logic enable,           // Enable signal
    input  logic serial_in,       // Serial input signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out       // Serial output signal
    output [15:0] diagnostic_bus  // Diagnostic output bus
    output logic error_flag       // Error flag output
    output logic error_counter     // Error counter output
;

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
    logic clk_pulse;              // Clock pulse for sampling
    logic prev_serial_in;         // Previous serial input for edge detection
    logic prev_value;             // Holds the previous value of serial_in
    logic nrz_out;                // NRZ encoding output
    logic rz_out;                 // Return-to-Zero encoding output
    logic diff_out;               // Differential encoding output
    logic inv_nrz_out;            // Inverted NRZ encoding output
    logic alt_invert_out;         // NRZ with alternating bit inversion output
    logic alt_invert_state;       // State for alternating inversion
    logic parity_out;             // Parity Bit Output
    logic scrambled_out;          // Scrambled NRZ output
    logic edge_triggered_out;     // Edge-Triggered NRZ output
    logic [15:0] diag_mode;       // Diagnostic mode signal
    logic [1] error_counter_bit;   // Error counter bit

    // Initialize error counter
    initial logic error_counter = 0;

    // Internal constants
    const SMALL_CONSTANT = 1;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
           clk_pulse <= 0;
            prev_value <= 0;
            prev_serial_in <= 0;
            error_flag <= 0;
            error_counter <= 0;
            diag_mode <= 00000000;
        end else if (enable) begin
            if (!reset_n) begin
                clk_counter <= 0;
               clk_pulse <= 0;
                prev_value <= 0;
                prev_serial_in <= 0;
                error_flag <= 0;
                error_counter <= 0;
                diag_mode <= 00000000;
            end else begin
                if (clk_counter == CLK_DIV - 1) begin
                   clk_counter <= 0;
                   clk_pulse <= 1;
                end else begin
                   clk_counter <= clk_counter + 1;
                   clk_pulse <= 0;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_value <= 0;
            prev_serial_in <= 0;
        end else begin
            prev_value <= serial_in;
            prev_serial_in <= prev_value;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else begin
            nrz_out <= serial_in;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            rz_out <= serial_in & (clk_pulse);
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else begin
            diff_out <= serial_in ^ prev_serial_in;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else begin
            inv_nrz_out <= ~serial_in;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out <= 0;
            alt_invert_state <= 0;
        end else begin
            alt_invert_state <= ~alt_invert_state;
            alt_invert_out <= alt_invert_state ? ~serial_in : serial_in;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else begin
            parity_out <= serial_in ^ parity_out;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else begin
            scrambled_out <= serial_in ^ (clk_counter[0]);
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end

    always_comb begin
        case (mode)
            3'b000: diag_mode <= 8'd00000000; serial_out <= nrz_out;
            3'b001: diag_mode <= 8'd00000001; serial_out <= rz_out;
            3'b010: diag_mode <= 8'd00000010; serial_out <= diff_out;
            3'b011: diag_mode <= 8'd00000011; serial_out <= inv_nrz_out;
            3'b100: diag_mode <= 8'd00000100; serial_out <= alt_invert_out;
            3'b101: diag_mode <= 8'd00000101; serial_out <= parity_out;
            3'b110: diag_mode <= 8'd00001000; serial_out <= scrambled_out;
            3'b111: diag_mode <= 8'd00001001; serial_out <= edge_triggered_out;
            default: serial_out <= 0;
        endcase
    end

    // Error detection and reporting
    always_comb begin
        if (enable) begin
            if (serial_in == 1'b1x || serial_in == 1'b1z) begin
                error_flag <= 1;
                error_counter <= error_counter + 1;
            end else begin
                error_flag <= 0;
                error_counter <= 0;
            end
        end
    end

    // Diagnostic bus assignment
    always_comb begin
        diag_mode <= (mode << 12) & 15;
        error_flag <= error_flag;
        error_counter <= (error_counter << 12) & 15;
        (3'b000)     // [3]: Clock pulse
        (2)          // [2]: Encoded output
        (1)          // [1]: Alternating bit inversion output
        (0)          // [0]: Parity bit output
    end