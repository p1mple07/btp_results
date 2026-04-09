module serial_line_code_converter #(parameter CLK_DIV = 16, parameter enable = 0)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low reset
    input  logic enable,          // Enable signal
    input  logic serial_in,       // Serial input signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out       // Serial output signal
);

    // Internal signals
    logic [3:0]clk_counter;      // Clock divider counter
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
    logic [16:0] diag_bus;        // Diagnostic output bus

    // Internal states
    logic [3:0] current_mode;     // Current encoding mode
    logic error_flag;             // Flag output indicating invalid input
    logic error_counter;           // Counts invalid input bits

    always_ff @(posedge clk or negedge reset_n or negedge enable) begin
        if (!reset_n && !enable) begin
            // Initialize all signals to default values
            clr all;
        end else if (enable) begin
            if (!reset_n) begin
                current_mode <= [2:0] '000;
                error_flag <= 0;
                error_counter <= 0;
            end else begin
                // Update current mode
                current_mode <= mode;
                
                // Update error state and counter
                if (serial_in == 1 && ( (mode & 8) == 1 || (mode & 4) == 1 )) begin
                    error_flag <= 1;
                    error_counter <= error_counter + 1;
                end
                
                // Other encoding logic remains the same
                // (NRZ, RZ, Differential, etc.)
                // ...
            end
        end else begin
            // Outputs are disabled
            serial_out <= 0;
            diag_bus <= 0;
            error_flag <= 0;
            error_counter <= 0;
        end
    end

    // Always comb logic for error detection
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
        
        // Diagnostic output bus
        diag_bus <= [
            current_mode,
            error_flag,
            error_counter,
            (clk_pulse ? 1 : 0),
            serial_out,
            alt_invert_out
        ];
    end

    // Other existing code remains the same...