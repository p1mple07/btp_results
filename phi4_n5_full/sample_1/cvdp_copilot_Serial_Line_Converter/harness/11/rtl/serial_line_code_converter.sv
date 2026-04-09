module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low reset
    input  logic serial_in,       // Serial input signal
    input  logic enable,          // Enable signal to control module operation
    input  logic [2:0] mode,      // Mode selector for encoding
    output logic serial_out,      // Encoded output signal
    output logic error_flag,      // Flag indicating an error (invalid serial_in)
    output logic [15:0] diagnostic_bus  // 16-bit diagnostic output bus
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
    logic parity_out;             // Parity Bit Output (Odd Parity)
    logic scrambled_out;          // Scrambled NRZ output
    logic edge_triggered_out;     // Edge-Triggered NRZ output

    // Error detection signals
    logic [7:0] error_counter;    // 8-bit error counter

    //--------------------------------------------------------------------------
    // 1. Clock Pulse Generation
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            clk_pulse   <= 0;
        end else if (clk_counter == CLK_DIV - 1) begin
            clk_counter <= 0;
            clk_pulse   <= 1;
        end else begin
            clk_counter <= clk_counter + 1;
            clk_pulse   <= 0;
        end
    end

    //--------------------------------------------------------------------------
    // 2. Previous Serial Input Tracking (only update when enabled)
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_value     <= 0;
            prev_serial_in <= 0;
        end else if (enable) begin
            prev_value     <= serial_in;
            prev_serial_in <= prev_value;
        end
    end

    //--------------------------------------------------------------------------
    // 3. Encoding Implementations (update only when enabled)
    //--------------------------------------------------------------------------
    // NRZ (Non-Return-to-Zero)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else if (enable) begin
            nrz_out <= serial_in;
        end
    end

    // RZ (Return-to-Zero)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else if (enable) begin
            rz_out <= serial_in & clk_pulse; 
        end
    end

    // Differential Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else if (enable) begin
            diff_out <= serial_in ^ prev_serial_in;
        end
    end

    // Inverted NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else if (enable) begin
            inv_nrz_out <= ~serial_in;
        end
    end

    // NRZ with Alternating Bit Inversion
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out    <= 0;
            alt_invert_state  <= 0;
        end else if (enable) begin
            alt_invert_state  <= ~alt_invert_state; 
            alt_invert_out    <= (alt_invert_state ? ~serial_in : serial_in);
        end
    end

    // Parity Bit Output (Odd Parity)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else if (enable) begin
            parity_out <= serial_in ^ parity_out; 
        end
    end

    // Scrambled NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else if (enable) begin
            scrambled_out <= serial_in ^ clk_counter[0]; 
        end
    end

    // Edge-Triggered NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else if (enable) begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end

    //--------------------------------------------------------------------------
    // 4. Error Detection and Counter Update (active only when enabled)
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            error_flag   <= 0;
            error_counter<= 0;
        end else if (enable) begin
            // Check for invalid serial_in (1'bx or 1'bz)
            if ((serial_in !== 1'b0) && (serial_in !== 1'b1)) begin
                error_flag   <= 1;
                error_counter<= error_counter + 1;
            end else begin
                error_flag   <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // 5. Select Encoded Output Based on Mode and Enable Signal
    //--------------------------------------------------------------------------
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

    //--------------------------------------------------------------------------
    // 6. Diagnostic Output Bus Construction
    //--------------------------------------------------------------------------
    // Bit Mapping:
    // [15:13] : Current mode (3 bits)
    // [12]    : Error flag
    // [11:4]  : Error counter (8 bits)
    // [3]     : Clock pulse status
    // [2]     : Encoded output (serial_out)
    // [1]     : Alternating bit inversion output (alt_invert_out)
    // [0]     : Parity bit output (parity_out)
    always_comb begin
        if (!enable) begin
            diagnostic_bus = 16'b0;
        end else begin
            diagnostic_bus[15:13] = mode;
            diagnostic_bus[12]    = error_flag;
            diagnostic_bus[11:4]  = error_counter;
            diagnostic_bus[3]     = clk_pulse;
            diagnostic_bus[2]     = serial_out;
            diagnostic_bus[1]     = alt_invert_out;
            diagnostic_bus[0]     = parity_out;
        end
    end

endmodule