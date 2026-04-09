module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,
    input  logic reset_n,
    input  logic serial_in,
    input  logic [2:0] mode,
    output logic serial_out
);

    // Internal registers
    logic [3:0] clk_counter;
    logic clk_pulse;
    logic prev_serial_in;
    logic prev_value;
    logic nrz_out;
    logic rz_out;
    logic diff_out;
    logic inv_nrz_out;
    logic alt_invert_out;
    logic parity_out;
    logic scrambled_out;
    logic edge_triggered_out;

    // Clock divider
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter == CLK_DIV - 1) clk_pulse <= 1;
            else clk_pulse <= 0;
        end
    end

    // NRZ – Straight pass‑through
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) nrz_out <= 0;
        else nrz_out <= serial_in;
    end

    // Return‑to‑Zero (RZ)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) rz_out <= 0;
        else rz_out <= serial_in;
    end

    // Differential Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) diff_out <= 0;
        else diff_out <= serial_in ^ prev_serial_in;
    end

    // Inverted NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) inv_nrz_out <= 0;
        else inv_nrz_out <= ~serial_in;
    end

    // NRZ with Alternating Bit Inversion
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) alt_invert_out <= 0;
        else alt_invert_out <= serial_in ^ (prev_value ^ 1);
    end

    // Parity Bit Output (Odd Parity)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) parity_out <= 0;
        else parity_out <= serial_in xor (parity_out);
    end

    // Scrambled NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) scrambled_out <= 0;
        else scrambled_out <= serial_in ^ (clock_counter % 2);
    end

    // Edge‑Triggered NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) edge_triggered_out <= 0;
        else edge_triggered_out <= (serial_in & ~prev_serial_in);
    end

    // Mux to select the appropriate output
    always_comb begin
        serial_out <= 
            CASE(mode)
                0: nrz_out,
                1: rz_out,
                2: diff_out,
                3: inv_nrz_out,
                4: alt_invert_out,
                5: parity_out,
                6: scrambled_out,
                7: edge_triggered_out,
                default: 0;
            end;
    end

endmodule
