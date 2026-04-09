module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low asynchronous reset
    input  logic serial_in,       // Serial input signal
    input  logic enable,          // Enable signal: when low, module is paused and outputs forced to 0
    input  logic [2:0] mode,      // Mode selector for encoding scheme
    output logic serial_out,      // Encoded output signal
    output logic error_flag,      // Flag indicating an error (invalid serial_in)
    output logic [15:0] diagnostic_bus  // Diagnostic output bus
);

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
    logic clk_pulse;              // Clock pulse for timing specific encodings
    logic prev_serial_in;         // Previous serial input for edge detection
    logic prev_value;             // Holds the previous value of serial_in
    logic nrz_out;                // NRZ encoding output
    logic rz_out;                 // Return-to-Zero encoding output
    logic diff_out;               // Differential encoding output
    logic inv_nrz_out;            // Inverted NRZ output
    logic alt_invert_out;         // NRZ with alternating bit inversion output
    logic alt_invert_state;       // State for alternating inversion
    logic parity_out;             // Parity Bit Output (Odd Parity)
    logic scrambled_out;          // Scrambled NRZ output
    logic edge_triggered_out;     // Edge-Triggered NRZ output
    logic [7:0] error_counter;    // 8-bit error counter tracking invalid serial_in events

    // Clock Pulse Generation (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            clk_pulse   <= 0;
        end else if (enable) begin
            if (clk_counter == CLK_DIV - 1) begin
                clk_counter <= 0;
                clk_pulse   <= 1;
            end else begin
                clk_counter <= clk_counter + 1;
                clk_pulse   <= 0;
            end
        end else begin
            // When module is disabled, force clock pulse and counter to 0.
            clk_counter <= 0;
            clk_pulse   <= 0;
        end
    end

    // Previous Serial Input Tracking (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_value      <= 0;
            prev_serial_in  <= 0;
        end else if (enable) begin
            prev_value      <= serial_in;
            prev_serial_in  <= prev_value;
        end else begin
            prev_value      <= 0;
            prev_serial_in  <= 0;
        end
    end

    // NRZ Encoding: Direct pass-through (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else if (enable) begin
            nrz_out <= serial_in;
        end else begin
            nrz_out <= 0;
        end
    end

    // RZ Encoding: High only during clock pulse (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else if (enable) begin
            rz_out <= serial_in & clk_pulse; 
        end else begin
            rz_out <= 0;
        end
    end

    // Differential Encoding: XOR of current and previous serial_in (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else if (enable) begin
            diff_out <= serial_in ^ prev_serial_in;
        end else begin
            diff_out <= 0;
        end
    end

    // Inverted NRZ Encoding: Invert the serial_in (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else if (enable) begin
            inv_nrz_out <= ~serial_in;
        end else begin
            inv_nrz_out <= 0;
        end
    end

    // NRZ with Alternating Bit Inversion (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out   <= 0;
            alt_invert_state <= 0;
        end else if (enable) begin
            alt_invert_state <= ~alt_invert_state; 
            alt_invert_out   <= alt_invert_state ? ~serial_in : serial_in;
        end else begin
            alt_invert_out   <= 0;
            alt_invert_state <= 0;
        end
    end

    // Parity Bit Output (Odd Parity): Compute parity bit (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else if (enable) begin
            parity_out <= serial_in ^ parity_out; 
        end else begin
            parity_out <= 0;
        end
    end

    // Scrambled NRZ: XOR serial_in with a bit from the clock counter (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else if (enable) begin
            scrambled_out <= serial_in ^ clk_counter[0]; 
        end else begin
            scrambled_out <= 0;
        end
    end

    // Edge-Triggered NRZ: High only on rising edge of serial_in (only active when enabled)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else if (enable) begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end else begin
            edge_triggered_out <= 0;
        end
    end

    // Error Detection: Check for invalid serial_in (1'bx or 1'bz) when enabled.
    // If an error is detected, error_flag is set and error_counter is incremented.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            error_counter <= 0;
            error_flag   <= 0;
        end else if (enable) begin
            if (serial_in === 1'bx || serial_in === 1'bz) begin
                error_flag   <= 1;
                error_counter<= error_counter + 1;
            end else begin
                error_flag   <= 0;
            end
        end else begin
            // When module is disabled, force error_flag to 0.
            error_flag <= 0;
        end
    end

    // Output Selection: Choose the encoded output based on the mode selector.
    // When disabled, force serial_out to 0.
    always_comb begin
        if (!enable) begin
            serial_out = 0;
        end else begin
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
        end
    end

    // Diagnostic Bus Formation:
    // [15:13] - Current mode (3 bits)
    // [12]    - Error flag
    // [11:4]  - Error counter (8 bits)
    // [3]     - Clock pulse status
    // [2]     - Encoded output (serial_out)
    // [1]     - NRZ with alternating bit inversion output (alt_invert_out)
    // [0]     - Parity bit output (parity_out)
    always_comb begin
        diagnostic_bus = { mode,         // [15:13]
                           error_flag,   // [12]
                           error_counter, // [11:4]
                           clk_pulse,    // [3]
                           serial_out,   // [2]
                           alt_invert_out, // [1]
                           parity_out }; // [0]
    end

endmodule