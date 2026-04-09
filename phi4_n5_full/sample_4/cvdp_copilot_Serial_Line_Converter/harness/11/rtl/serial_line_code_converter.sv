module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low asynchronous reset
    input  logic serial_in,       // Serial input signal
    input  logic enable,          // Module enable signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out,      // Encoded output signal
    output logic error_flag,      // Error flag output
    output logic [15:0] diagnostic_bus  // 16-bit diagnostic bus
);

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
    logic clk_pulse;              // Clock pulse for timing-specific encodings
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

    // Clock pulse generation (gated by enable)
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
        end
        // else: hold state when enable is low
    end

    // Previous serial input tracking (gated by enable)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_value     <= 0;
            prev_serial_in <= 0;
        end else if (enable) begin
            prev_value     <= serial_in;
            prev_serial_in <= prev_value;
        end
        // else: hold state when enable is low
    end

    // NRZ (Non-Return-to-Zero) encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else if (enable) begin
            nrz_out <= serial_in;
        end
        // else: hold state when enable is low
    end

    // RZ (Return-to-Zero) encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else if (enable) begin
            rz_out <= serial_in & clk_pulse;
        end
        // else: hold state when enable is low
    end

    // Differential Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else if (enable) begin
            diff_out <= serial_in ^ prev_serial_in;
        end
        // else: hold state when enable is low
    end

    // Inverted NRZ encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else if (enable) begin
            inv_nrz_out <= ~serial_in;
        end
        // else: hold state when enable is low
    end

    // NRZ with Alternating Bit Inversion
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out  <= 0;
            alt_invert_state<= 0;
        end else if (enable) begin
            alt_invert_state<= ~alt_invert_state;
            alt_invert_out  <= (alt_invert_state ? ~serial_in : serial_in);
        end
        // else: hold state when enable is low
    end

    // Parity Bit Output (Odd Parity)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else if (enable) begin
            // Compute odd parity: XOR current serial_in with previous parity_out
            parity_out <= serial_in ^ parity_out;
        end
        // else: hold state when enable is low
    end

    // Scrambled NRZ encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else if (enable) begin
            scrambled_out <= serial_in ^ clk_counter[0];
        end
        // else: hold state when enable is low
    end

    // Edge-Triggered NRZ encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else if (enable) begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
        // else: hold state when enable is low
    end

    // Error Detection: Check for invalid serial_in values (1'bx or 1'bz)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            error_flag   <= 0;
            error_counter<= 0;
        end else if (enable) begin
            if (serial_in !== 0 && serial_in !== 1) begin
                error_flag   <= 1;
                error_counter<= error_counter + 1;
            end else begin
                error_flag <= 0;
            end
        end
        // else: hold state when enable is low
    end

    // Output Assignment and Diagnostic Bus Generation
    always_comb begin
        if (!enable) begin
            // When disabled, force outputs to 0
            serial_out         = 0;
            diagnostic_bus     = 16'b0;
        end else begin
            // Select encoded output based on mode selector
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

            // Pack diagnostic information into the 16-bit bus:
            // [15:13]  - Current mode (3 bits)
            // [12]     - Error flag (1 bit)
            // [11:4]   - Error counter (8 bits)
            // [3]      - Clock pulse status (1 bit)
            // [2]      - Encoded output (1 bit)
            // [1]      - Alternating inversion output (1 bit)
            // [0]      - Parity bit output (1 bit)
            diagnostic_bus = { mode, error_flag, error_counter, clk_pulse, serial_out, alt_invert_out, parity_out };
        end
    end

endmodule