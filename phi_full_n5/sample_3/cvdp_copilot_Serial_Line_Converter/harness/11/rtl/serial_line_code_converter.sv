module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low asynchronous reset
    input  logic serial_in,       // Serial input signal
    input  logic enable,          // Enable signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out       // Serial output signal
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
    logic alt_invert_out;         // NRZ with Alternating Bit Inversion output
    logic alt_invert_state;       // State for Alternating Bit Inversion
    logic parity_out;             // Parity Bit Output
    logic scrambled_out;          // Scrambled NRZ output
    logic edge_triggered_out;     // Edge-Triggered NRZ output
    logic error_flag;             // Error detection flag
    logic error_counter;          // Error counter
    logic diagnostic_bus [15:0];  // Diagnostic bus

    // Enable signal control
    always @ (posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            clk_pulse <= 0;
            serial_out <= 0;
            enable <= 0;
            prev_value <= 0;
            prev_serial_in <= 0;
            error_flag <= 0;
            error_counter <= 0;
            diagnostic_bus <= 16'b0;
        end else if (enable) begin
            clk_counter <= clk_counter + 1;
            clk_pulse <= (clk_counter == CLK_DIV - 1) ? 1'b1 : 1'b0;
            serial_out <= (mode == 3'b000) ? nrz_out : (mode == 3'b001) ? rz_out :
                                            (mode == 3'b010) ? diff_out : (mode == 3'b011) ? inv_nrz_out :
                                            (mode == 3'b100) ? alt_invert_out : (mode == 3'b101) ? parity_out :
                                            (mode == 3'b110) ? scrambled_out : (mode == 3'b111) ? edge_triggered_out : 0;
            diagnostic_bus <= {(mode >> 2), error_flag, error_counter, clk_pulse, nrz_out, rz_out, diff_out, inv_nrz_out, alt_invert_out, parity_out, scrambled_out, edge_triggered_out};
        end
    end

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
            default: serial_out = 0;                     
        endcase
    end

endmodule
