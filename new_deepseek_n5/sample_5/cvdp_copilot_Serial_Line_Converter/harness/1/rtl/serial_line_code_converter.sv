module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low reset
    input  logic serial_in,       // Serial input signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out       // Serial output signal
);

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
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

    // Clock Pulse Generation
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            prev_serial_in <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter == (CLK_DIV - 1)) begin
                clk_pulse <= 1;
                clk_counter <= 0;
            end
            prev_serial_in <= serial_in;
        end
    end

    // Return-to-Zero Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            if (prev_serial_in == 0 && serial_in == 1) begin
                rz_out <= 1;
            else
                rz_out <= 0;
            end
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
            alt_invert_out <= 0;
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
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end

    // Output Multiplexer
    always_ff @(posedge clk or negedge reset_n) begin
        if (mode == 0b000) begin
            serial_out <= nrz_out;
        elsif (mode == 0b001) begin
            serial_out <= rz_out;
        elsif (mode == 0b010) begin
            serial_out <= diff_out;
        elsif (mode == 0b011) begin
            serial_out <= inv_nrz_out;
        elsif (mode == 0b100) begin
            serial_out <= alt_invert_out;
        elsif (mode == 0b101) begin
            serial_out <= parity_out;
        elsif (mode == 0b110) begin
            serial_out <= scrambled_out;
        elsif (mode == 0b111) begin
            serial_out <= edge_triggered_out;
        else begin
            serial_out <= 0;
        end
    end
endmodule