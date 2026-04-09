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
    logic inv_nrz_out;            // Inverted NRZ encoding output
    logic alt_invert_out;         // NRZ with alternating bit inversion output
    logic alt_invert_state;       // State for alternating inversion
    logic parity_out;             // Cumulative XOR for parity calculation
    logic scrambled_out;          // Scrambled NRZ output
    logic edge_triggered_out;     // Edge-Triggered NRZ output

    // Clock Pulse Generation
    // Divide the system clock by CLK_DIV and generate a pulse when the counter reaches CLK_DIV - 1.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            clk_counter <= 0;
        else begin
            if (clk_counter == CLK_DIV - 1)
                clk_counter <= 0;
            else
                clk_counter <= clk_counter + 1;
        end
    end

    assign clk_pulse = (clk_counter == CLK_DIV - 1);

    // Previous Serial Input Tracking for edge detection
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_value <= 0;
            prev_serial_in <= 0;
        end else begin
            prev_value <= serial_in;
            prev_serial_in <= prev_value;
        end
    end

    // NRZ Pass-Through (direct output of serial_in)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            nrz_out <= 0;
        else
            nrz_out <= serial_in;
    end

    // Return-to-Zero (RZ) Encoding
    // Output high only during the first half of the clock cycle when serial_in is high.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            rz_out <= 0;
        else begin
            if (clk_pulse)
                rz_out <= serial_in;  // Sample serial_in on clk_pulse
            else
                rz_out <= 0;
        end
    end

    // Differential Encoding
    // Compute the output by XORing the current serial_in with the previous serial input.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            diff_out <= 0;
        else
            diff_out <= serial_in ^ prev_serial_in;
    end

    // Inverted NRZ Encoding
    // Generate the output by inverting the serial_in signal.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            inv_nrz_out <= 0;
        else
            inv_nrz_out <= ~serial_in;
    end

    // NRZ with Alternating Bit Inversion
    // Toggle inversion on each clock cycle: alternate between inverted and non-inverted serial_in.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_state <= 0;
            alt_invert_out <= 0;
        end else begin
            alt_invert_state <= ~alt_invert_state;  // Toggle state each cycle
            if (alt_invert_state)
                alt_invert_out <= ~serial_in;
            else
                alt_invert_out <= serial_in;
        end
    end

    // Parity Bit Output (Odd Parity Calculation)
    // Generate an odd parity bit by computing the cumulative XOR of received bits.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            parity_out <= 0;
        else
            parity_out <= parity_out ^ serial_in;
    end

    // Scrambled NRZ (Simple XOR with a fixed pattern)
    // XOR serial_in with the LSB of the clock counter to scramble the signal.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            scrambled_out <= 0;
        else
            scrambled_out <= serial_in ^ clk_counter[0];
    end

    // Edge-Triggered NRZ
    // Detect rising edges of serial_in and output accordingly.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            edge_triggered_out <= 0;
        else
            edge_triggered_out <= (serial_in & ~prev_serial_in);
    end

    // Output Multiplexer: Select the encoding output based on the mode input.
    // Valid modes: 000: NRZ, 001: RZ, 010: Differential, 011: Inverted NRZ,
    // 100: Alternating Bit Inversion, 101: Odd Parity, 110: Scrambled NRZ, 111: Edge-Triggered NRZ.
    always_comb begin
        case(mode)
            3'd0: serial_out = nrz_out;         // NRZ
            3'd1: serial_out = rz_out;          // RZ
            3'd2: serial_out = diff_out;        // Differential Encoding
            3'd3: serial_out = inv_nrz_out;     // Inverted NRZ
            3'd4: serial_out = alt_invert_out;  // NRZ with Alternating Bit Inversion
            3'd5: serial_out = ~parity_out;     // Odd Parity Bit Output (complement of cumulative XOR)
            3'd6: serial_out = scrambled_out;   // Scrambled NRZ
            3'd7: serial_out = edge_triggered_out; // Edge-Triggered NRZ
            default: serial_out = 1'b0;         // Invalid mode defaults to 0.
        endcase
    end

endmodule