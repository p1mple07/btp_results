module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low asynchronous reset
    input  logic serial_in,       // Serial input signal
    input  logic enable,          // Enable signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out,     // Serial output signal
    output logic error_flag,     // Error flag
    output logic [15:0] diagnostic_bus // Diagnostic bus
);

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
    logic clk_pulse;              // Clock pulse for timing
    logic prev_serial_in;         // Previous serial input for edge detection
    logic prev_value;             // Holds the previous value of serial_in
    logic nrz_out,                // NRZ encoding output
    rz_out,                      // Return-to-Zero encoding output
    diff_out,                    // Differential encoding output
    inv_nrz_out,                // Inverted NRZ output
    alt_invert_out,             // NRZ with alternating bit inversion output
    alt_invert_state,           // State for alternating inversion
    logic parity_out,            // Parity bit output
    scrambled_out,              // Scrambled NRZ output
    edge_triggered_out,         // Edge-Triggered NRZ output
    logic error_counter,        // Error counter

    // Enable signal control
    always @(posedge clk or negedge reset_n or posedge enable) begin
        if (reset_n) begin
            clk_counter <= 0;
            clk_pulse <= 0;
            serial_out <= 0;
            error_flag <= 0;
            diagnostic_bus <= 0;
        end else if (enable) begin
            clk_counter <= clk_counter + 1;
            clk_pulse <= (clk_counter == CLK_DIV - 1) ? 1'b1 : 1'b0;
            serial_out <= {[15:2]diagnostic_bus, serial_out};
            error_flag <= (serial_in === 1'bx || serial_in === 1'bz) ? 1'b1 : 1'b0;
            error_counter <= error_counter + (serial_in === 1'bx || serial_in === 1'bz) ? 8'd1 : 8'd0;
        end
    end

    // Encoding schemes
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_value <= 0;
            prev_serial_in <= 0;
        end else begin
            prev_value <= serial_in;
            prev_serial_in <= prev_value;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else begin
            nrz_out <= serial_in;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            rz_out <= serial_in & clk_pulse;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else  begin
            diff_out <= serial_in ^ prev_serial_in;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else  begin
            inv_nrz_out <= ~serial_in;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out <= 0;
            alt_invert_state <= 0;
        end else  begin
            alt_invert_state <= ~alt_invert_state; 
            alt_invert_out <= alt_invert_state ? ~serial_in : serial_in;
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
