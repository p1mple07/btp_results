module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low asynchronous reset
    input  logic serial_in,       // Serial input signal
    input  logic enable,          // Enable signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out       // Serial output signal
    , output logic error_flag       // Error flag
    , output logic [15:0] diagnostic_bus // Diagnostic bus
);

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
    logic clk_pulse;              // Clock pulse for timing-specific encodings
    logic prev_serial_in;         // Previous serial input for edge detection
    logic prev_value;             // Holds the previous value of serial_in
    logic error_counter [7:0];    // Error counter

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            clk_pulse <= 0;
            prev_serial_in <= 0;
            prev_value <= 0;
            error_counter <= 8'h00;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter == CLK_DIV - 1) begin
                clk_pulse <= 1;
                clk_counter <= 0;
            end else begin
                clk_pulse <= 0;
            end
            prev_serial_in <= prev_serial_in;
            prev_value <= serial_in;
            error_counter <= error_counter + 1'b0; // Increment error counter on invalid input
        end
    end

    always_comb begin
        case (mode)
            3'd0: serial_out = ~serial_in;
            3'd1: serial_out = serial_in;
            3'd2: serial_out = ~serial_in ^ clk_pulse;
            3'd3: serial_out = ~serial_in ^ ~prev_serial_in;
            3'd4: serial_out = serial_in ^ ~prev_serial_in;
            3'd5: serial_out = serial_in ^ ~prev_value;
            3'd6: serial_out = ~serial_in ^ prev_value;
            3'd7: serial_out = (serial_in & ~prev_serial_in) | (~serial_in & prev_value);
            3'd8: serial_out = ~serial_in;
            3'd9: serial_out = serial_in ^ parity_out;
            default: serial_out = 0;
        endcase
    end

    // Diagnostic bus assignments
    assign diagnostic_bus[15:13] = {mode};
    assign diagnostic_bus[12] = error_flag;
    assign diagnostic_bus[11:4] = error_counter;
    assign diagnostic_bus[3] = clk_pulse;
    assign diagnostic_bus[2] = serial_out;
    assign diagnostic_bus[1] = (alt_invert_state ? ~serial_in : serial_in) & ~clk_pulse; // NRZ with Alternating Bit Inversion
    assign diagnostic_bus[0] = parity_out; // Parity bit output

endmodule
 module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,             // System clock
    input  logic reset_n,         // Active-low asynchronous reset
    input  logic serial_in,       // Serial input signal
    input  logic enable,          // Enable signal
    input  logic [2:0] mode,      // Mode selector
    output logic serial_out       // Serial output signal
    , output logic error_flag       // Error flag
    , output logic [15:0] diagnostic_bus // Diagnostic bus
);

    // Internal signals
    logic [3:0] clk_counter;      // Clock divider counter
    logic clk_pulse;              // Clock pulse for timing-specific encodings
    logic prev_serial_in;         // Previous serial input for edge detection
    logic prev_value;             // Holds the previous value of serial_in
    logic error_counter [7:0];    // Error counter
    logic alt_invert_state;       // State for alternating inversion
    logic inv_nrz_out;            // Inverted NRZ output

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
            clk_pulse <= 0;
            prev_serial_in <= 0;
            prev_value <= 0;
            error_counter <= 8'h00;
            error_flag <= 1'b0;
            alt_invert_state <= 0;
            inv_nrz_out <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter == CLK_DIV - 1) begin
                clk_pulse <= 1;
                clk_counter <= 0;
            end else begin
                clk_pulse <= 0;
            end
            prev_serial_in <= prev_serial_in;
            prev_value <= serial_in;
            error_counter <= error_counter + 1'b0; // Increment error counter on invalid input
        end
    end

    always_comb begin
        case (mode)
            3'd0: serial_out = ~serial_in;
            3'd1: serial_out = serial_in;
            3'd2: serial_out = ~serial_in ^ clk_pulse;
            3'd3: serial_out = ~serial_in ^ ~prev_serial_in;
            3'd4: serial_out = serial_in ^ ~prev_serial_in;
            3'd5: serial_out = serial_in ^ ~prev_value;
            3'd6: serial_out = ~serial_in ^ prev_value;
            3'd7: serial_out = (serial_in & ~prev_serial_in) | (~serial_in & prev_value);
            3'd8: serial_out = ~serial_in;
            3'd9: serial_out = serial_in ^ inv_nrz_out;
            default: serial_out = 0;
        endcase
    end

    // Error detection and diagnostic bus assignments
    always_comb begin
        if (serial_in === 1'bx || serial_in === 1'bz) begin
            error_flag <= 1'b1;
            error_counter <= error_counter + 1'h0;
        end else begin
            error_flag <= 1'b0;
        end
    end

    assign diagnostic_bus[15:13] = {mode};
    assign diagnostic_bus[12] = error_flag;
    assign diagnostic_bus[11:4] = error_counter;
    assign diagnostic_bus[3] = clk_pulse;
    assign diagnostic_bus[2] = serial_out;
    assign diagnostic_bus[1] = inv_nrz_out; // Inverted NRZ output
    assign diagnostic_bus[0] = (alt_invert_state ? ~serial_in : serial_in) ^ ~clk_pulse; // NRZ with Alternating Bit Inversion

endmodule