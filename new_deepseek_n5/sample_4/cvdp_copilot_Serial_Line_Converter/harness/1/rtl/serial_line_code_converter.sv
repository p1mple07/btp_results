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
            clk_pulse <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter == CLK_DIV - 1) begin
                clk_pulse <= 1;
                clk_counter <= 0;
            end
            else begin
                clk_pulse <= 0;
            end
        end
    end

    // Return-to-Zero Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            if (clk_pulse) begin
                rz_out <= serial_in & ~prev_serial_in;
            else begin
                rz_out <= 0;
            end
        end
    end

    // Differential Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else begin
            diff_out <= serial_in ^ prev_serial_in;
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
            alt_invert_out <= 0;
            alt_invert_state <= 0;
        end else begin
            alt_invert_out <= serial_in ^ alt_invert_state;
            alt_invert_state <= ~alt_invert_state;
        end
    end

    // Parity Bit Output
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else begin
            parity_out <= parity_out ^ serial_in;
        end
    end

    // Scrambled NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else begin
            scrambled_out <= serial_in ^ (clk_counter & 1);
        end
    end

    // Edge-Triggered NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else begin
            edge_triggered_out <= serial_in ^ prev_serial_in;
        end
    end

    // Output Multiplexer
    integer mode_val = (mode [2:0]);
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
            rz_out <= 0;
            diff_out <= 0;
            inv_nrz_out <= 0;
            alt_invert_out <= 0;
            parity_out <= 0;
            scrambled_out <= 0;
            edge_triggered_out <= 0;
        end else if (mode_val < 8) begin
            case (mode_val)
                0: serial_out <= nrz_out;
                1: serial_out <= rz_out;
                2: serial_out <= diff_out;
                3: serial_out <= inv_nrz_out;
                4: serial_out <= alt_invert_out;
                5: serial_out <= parity_out;
                6: serial_out <= scrambled_out;
                7: serial_out <= edge_triggered_out;
                default: serial_out <= 0;
            endcase
        else begin
            serial_out <= 0;
        end
    end
endmodule