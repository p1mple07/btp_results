module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low reset
    input  logic serial_in,       // Serial input signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out       // Serial output signal
);

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
    logic clk_pulse;              // Clock pulse for sampling
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

    // Clock Pulse Generation
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter == CLK_DIV - 1) begin
                clk_pulse <= ~clk_pulse; // Toggle clk_pulse
                clk_counter <= 0;
            end
        end
    end

    // Return-to-Zero (RZ) Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            rz_out <= (clk_pulse & (serial_in ^ (serial_in & prev_value)));
        end
    end

    // Differential Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else begin
            diff_out <= serial_in ^ prev_value;
        end
    end

    // Inverted NRZ Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else begin
            inv_nrz_out <= ~serial_in;
        end
    end

    // NRZ with Alternating Bit Inversion
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_state <= 0;
        } else begin
            alt_invert_state <= ~alt_invert_state;
            alt_invert_out <= alt_invert_state ^ serial_in;
        end
    end

    // Parity Bit Output (Odd Parity Calculation)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else begin
            parity_out <= serial_in ^ (serial_in ^ prev_value);
        end
    end

    // Scrambled NRZ (Simple XOR with a fixed pattern)
    always_ff @(posedge clk or negedge reset_n) begin
        scrambled_out <= serial_in ^ clk_counter[0];
    end

    // Edge-Triggered NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        edge_triggered_out <= serial_in & ~prev_serial_in;
    end

    // Output Multiplexer to a single output
    assign serial_out = (mode == 0) ? nrz_out :
                        (mode == 1) ? rz_out :
                        (mode == 2) ? diff_out :
                        (mode == 3) ? inv_nrz_out :
                        (mode == 4) ? alt_invert_out :
                        (mode == 5) ? parity_out :
                        (mode == 6) ? scrambled_out :
                        edge_triggered_out;

endmodule
