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
    always @(posedge clk) begin
        if (clk_counter == CLK_DIV - 1) begin
            clk_pulse <= ~clk_pulse;
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end

    // Return-to-Zero (RZ) Encoding
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            rz_out <= (clk_pulse & serial_in);
        end
    end

    // Differential Encoding
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else begin
            diff_out <= (serial_in ^ prev_value);
        end
    end

    // Inverted NRZ Encoding
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        } else begin
            inv_nrz_out <= ~serial_in;
        end
    end

    // NRZ with Alternating Bit Inversion
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out <= 0;
        end else begin
            alt_invert_out <= (alt_invert_state & ~serial_in);
        end
    end

    // Parity Bit Output (Odd Parity Calculation)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else begin
            parity_out <= (serial_in ^ prev_value ^ serial_in);
        end
    end

    // Scrambled NRZ (Simple XOR with a fixed pattern)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else begin
            scrambled_out <= (serial_in ^ clk_counter[0]);
        end
    end

    // Edge-Triggered NRZ
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end

    // Output Multiplexer
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            serial_out <= nrz_out;
        end else begin
            case (mode)
                3'b000: serial_out <= nrz_out;
                3'b001: serial_out <= rz_out;
                3'b010: serial_out <= diff_out;
                3'b011: serial_out <= inv_nrz_out;
                3'b100: serial_out <= alt_invert_out;
                3'b101: serial_out <= parity_out;
                3'b110: serial_out <= scrambled_out;
                3'b111: serial_out <= edge_triggered_out;
                default: serial_out <= 0;
            endcase
        end
    end

endmodule
