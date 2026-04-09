module nmea_decoder (
    input wire clk,
    input wire reset,
    input wire [7:0] serial_in,         // ASCII character input
    input wire serial_valid,            // Valid signal for character
    output reg [15:0] data_out,         // Decoded 16-bit output
    output reg data_valid               // Valid signal for output
);

    // ... (existing state definitions and combinational logic) ...

    // Counter for the number of characters processed
    reg [6:0] char_count;
    // Counter for the time between characters (watchdog)
    reg [6:0] watchdog_counter;
    // Flag to detect if a newline (or carriage return) was not seen within a window
    reg watchdog_timeout;

    // ... (rest of the combinational logic) ...

    // Trigger watchdog timeout if no carriage return for more than a few cycles
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            char_count <= 0;
            watchdog_counter <= 0;
            watchdog_timeout <= 0;
        end else begin
            char_count <= char_count + 1;
            watchdog_counter <= watchdog_counter + 1;
            if (char_count > 10) watchdog_timeout <= 1;
        end
    end

    // Trigger output only when a carriage return is seen
    always @(posedge clk or posedge reset) begin
        if (serial_valid && is_end) begin
            next_state = STATE_OUTPUT;
        end
    end

    // ... (remaining combinational logic unchanged) ...

endmodule
