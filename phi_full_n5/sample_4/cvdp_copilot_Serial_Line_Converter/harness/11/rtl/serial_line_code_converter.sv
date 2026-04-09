module serial_line_code_converter #(parameter CLK_DIV = 16, parameter ENABLE_WIDTH = 1)(
    input wire clk,                         // System clock
    input wire reset_n,                     // Active-low asynchronous reset
    input wire enable,                      // Enable signal to control module functionality
    input wire [2:0] mode,                  // Mode selector
    input wire [15:0] serial_in,             // Serial input signal
    output reg serial_out,                  // Serial output signal
    output reg error_flag,                  // Error flag
    output reg [15:0] diagnostic_bus         // Diagnostic output bus
);

    // Internal signals
    reg [3:0] clk_counter;                  // Clock divider counter
    reg clk_pulse;                          // Clock pulse for timing specific encodings
    reg prev_serial_in;                     // Previous serial input for edge detection
    reg prev_value;                         // Holds the previous value of serial_in
    reg nrz_out;                            // NRZ encoding output
    reg rz_out;                             // Return-to-Zero encoding output
    reg diff_out;                           // Differential encoding output
    reg inv_nrz_out;                        // Inverted NRZ output
    reg alt_invert_out;                     // NRZ with alternating bit inversion output
    reg alt_invert_state;                   // State for alternating inversion
    reg parity_out;                         // Parity bit output
    reg scrambled_out;                      // Scrambled NRZ output
    reg edge_triggered_out;                // Edge-Triggered NRZ output
    reg error_counter [7:0];                // Error counter

    // Enable control logic
    always @(posedge clk or negedge reset_n) begin
        if (reset_n) begin
            clk_counter <= 0;
            clk_pulse <= 0;
            serial_out <= 0;
            error_flag <= 0;
            diagnostic_bus <= 16'b0000000000000000;
        end else if (enable) begin
            serial_out <= #1 serial_in; // Sync assignment for enable logic
            diagnostic_bus <= (
                {15:13} mode,
                {12} error_flag,
                {11:4} error_counter,
                {3} clk_pulse,
                {2} nrz_out,
                {1} alt_invert_out,
                {0} parity_out
            );
        end else begin
            clk_counter <= 0;
            clk_pulse <= 0;
        end
    end

    // Clock pulse generation
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
        end else if (clk_counter == CLK_DIV - 1) begin
            clk_pulse <= 1;
        end else begin
            clk_counter <= clk_counter + 1;
            clk_pulse <= 0;
        end
    end

    // Previous serial input tracking
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_value <= 0;
            prev_serial_in <= 0;
        end else begin
            prev_value <= serial_in;
            prev_serial_in <= prev_value;
        end
    end

    // Encoding implementations
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

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else  begin
            parity_out <= serial_in ^ parity_out; 
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else  begin
            scrambled_out <= serial_in ^ clk_counter[0]; 
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else  begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end

    // Encoding selection logic
    always_comb begin
        case (mode)
            3'b000: begin
                serial_out <= nrz_out;
                diagnostic_bus[15:13] <= 3'b000;
            end
            3'b001: begin
                serial_out <= rz_out;
                diagnostic_bus[15:13] <= 3'b001;
            end
            3'b010: begin
                serial_out <= diff_out;
                diagnostic_bus[15:13] <= 3'b010;
            end
            3'b011: begin
                serial_out <= inv_nrz_out;
                diagnostic_bus[15:13] <= 3'b011;
            end
            3'b100: begin
                serial_out <= alt_invert_out;
                diagnostic_bus[15:13] <= 3'b100;
            end
            3'b101: begin
                serial_out <= parity_out;
                diagnostic_bus[15:13] <= 3'b101;
            end
            3'b110: begin
                serial_out <= scrambled_out;
                diagnostic_bus[15:13] <= 3'b110;
            end
            3'b111: begin
                serial_out <= edge_triggered_out;
                diagnostic_bus[15:13] <= 3'b111;
            end
            default: begin
                serial_out <= 0;
                error_flag <= 1; // Error flag set for invalid mode
                diagnostic_bus[12] <= 1; // Error flag on diagnostic bus
                error_counter <= 8'b00000000; // Initialize error counter
            end
            diagnostic_bus[11:4] <= 8'b00000000; // Reset error counter
            break;
        endcase
    end

    // Error detection logic
    always @(serial_in) begin
        if (serial_in == 1'bx || serial_in == 1'bz) begin
            error_flag <= 1;
            error_counter <= error_counter + 1;
            diagnostic_bus[12] <= 1; // Error flag on diagnostic bus
        end else begin
            diagnostic_bus[12] <= 0;
        end
    end

endmodule
