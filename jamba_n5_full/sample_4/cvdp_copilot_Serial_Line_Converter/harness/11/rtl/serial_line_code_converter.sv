module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low reset
    input  logic serial_in,       // Serial input signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out,      // Serial output signal
    output logic enable,           // Enable signal
    output logic error_flag,       // Error flag
    output logic error_counter,    // 8‑bit error counter
    output logic [15:0] diagnostic_bus([15:13] to [0]),
    output logic clk_pulse,       // Clock pulse
    output logic clk_divisor_generated,
    output logic [3:0] clock_div,
    output logic prev_serial_in,
    output logic prev_value,
    output logic nrz_out,
    output logic rz_out,
    output logic diff_out,
    output logic inv_nrz_out,
    output logic alt_invert_out,
    output logic alt_invert_state,
    output logic parity_out,
    output scrambled_out,
    output edge_triggered_out
);

// ------------------------------------------------------------------
// Main synchronous clock domain
// ------------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        serial_out <= 0;
        enable <= 0;
        error_flag <= 1;
        error_counter <= 8'd0;
        diagnostic_bus([15:13] to [0]) <= 16'b"ERROR";
        clk_pulse <= 0;
        clk_divisor_generated <= 0;
        clock_div <= 0;
        prev_serial_in <= 0;
        prev_value <= 0;
        nrz_out <= 0;
        rz_out <= 0;
        diff_out <= 0;
        inv_nrz_out <= 0;
        alt_invert_out <= 0;
        alt_invert_state <= 0;
        parity_out <= 0;
        scrambled_out <= 0;
        edge_triggered_out <= 0;
    end
    else begin
        if (enable) begin
            // Clock pulse generation (simplified)
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    clk_counter <= 0;
                    clk_pulse <= 0;
                end else if (clk_counter == CLK_DIV - 1) begin
                    clk_counter <= 0;
                    clk_pulse <= 1;
                end else begin
                    clk_counter <= clk_counter + 1;
                    clk_pulse <= 0;
                end
            end

            // NRZ encoding
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    prev_value <= 0;
                    prev_serial_in <= 0;
                end else begin
                    prev_value <= serial_in;
                    prev_serial_in <= prev_value;
                end
            end

            // RZ encoding
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    prev_value <= serial_in & clk_pulse;
                    prev_serial_in <= serial_in;
                end
            end

            // Differential encoding
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    diff_out <= serial_in ^ prev_serial_in;
                end
            end

            // Inverted NRZ
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    inv_nrz_out <= ~serial_in;
                end
            end

            // NRZ with alternating bit inversion
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    alt_invert_state <= ~alt_invert_state;
                    alt_invert_out <= alt_invert_state ? ~serial_in : serial_in;
                end
            end

            // Parity bit output
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    parity_out <= serial_in ^ parity_out;
                end
            end

            // Scrambled NRZ
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    scrambled_out <= serial_in ^ clk_counter[0];
                end
            end

            // Edge‑triggered NRZ
            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    edge_triggered_out <= (serial_in & ~prev_serial_in);
                end
            end

            // Diagnostics
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
                    default: serial_out <= 0;
                endcase
            end
        end
    end
end @(posedge clk or negedge reset_n)

// ------------------------------------------------------------------
// Post‑clock combinational logic
// ------------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        clk_pulse <= 0;
        clk_divisor_generated <= 0;
        clock_div <= 0;
        prev_serial_in <= 0;
        prev_value <= 0;
        nrz_out <= 0;
        rz_out <= 0;
        diff_out <= 0;
        inv_nrz_out <= 0;
        alt_invert_out <= 0;
        alt_invert_state <= 0;
        parity_out <= 0;
        scrambled_out <= 0;
        edge_triggered_out <= 0;
        error_flag <= 0;
        error_counter <= 8'd0;
        diagnostic_bus([15:13] to [0]) <= 16'b"IDLE";
    end else begin
        // Use the same combinational logic as above
    end
end
