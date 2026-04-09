// **Module Implementation**
module nmea_decoder (
    input wire [15:0] serial_in,           // ASCII encoded NMEA sentence
    input wire serial_valid,              // Valid character
    input wire [1:0] serial Identifiers,  // GPRMC-specific
    output reg [15:0] data_out,          // First data field converted to binary
    output reg data_out_bin,              // Binary representation of data field
    output reg data_valid,                // Data validity flag
    output reg data_bin_valid,            // Flag indicating valid hex conversion
    output reg error_overflow,            // Overflow detected
    output reg watchdog_timeout           // Timeout detection
);

    // FSM States
    localparam 
        STATE_0   = 0,
        STATE_IN  = 1,
        STATE_PARSE = 2,
        STATE_OUTPUT = 3,
        STATE_TIMEOUT = 4,

    // Configuration
    localparam MAX_BUFFER_SIZE = 80;
    localparam WATCHDOG_TIMEOUT = 100;

    // Internal registers
    reg [7:0] buffer [0:MAX_BUFFER_SIZE-1];  // Sentence buffer
    reg [6:0] buffer_index;                  // Current buffer index
    reg [1:0] state;                       // Finite State Machine (FSM) states
    reg [6:0] comma_count;                  // Comma counter
    reg [6:0] field_index;                  // Field position tracker

    // Character identifiers
    wire is_start = (serial_in == 8'h24);     // '$'
    wire is_comma = (serial_in == 8'h2C);     // ','
    wire is_end = (serial_in == 8'h0D);      // '\r'

    // Sequential logic (clocked)
    always @(*) begin
        // Register transitions (simplified)
        next_state = state;
        
        case (state)
            STATE_0: begin
                if (reset || !is_start) begin
                    next_state = STATE_IN;
                end else begin
                    state = STATE_IN;
                end
            end

            STATE_IN: begin
                if (is_start) begin
                    buffer[0] = serial_in;
                    buffer_index = 0;
                    state = STATE_PARSE;
                end else if (is_comma) begin
                    buffer_next_index = buffer_index + 1;
                    if (buffer_index < MAX_BUFFER_SIZE-1) begin
                        buffer[buffer_next_index] = serial_in;
                        next_buffer_index = buffer_next_index;
                    end else begin
                        // Buffer overflow
                        error_overflow = 1;
                        next_state = STATE_TIMEOUT;
                    end
                end else if (!is_end) begin
                    next_state = STATE_IN;
                end
            end

            STATE_PARSE: begin
                if (is_end) begin
                    for (i = 0; i < MAX_BUFFER_SIZE; i = i + 1) begin
                        if (i < buffer_index) begin
                            if (buffer[i] == 8'h47 && buffer[i+1] == 8'h50) begin
                                field_index = i + 1;  // First data field
                            end
                        end
                    end
                    if (field_index+1 < buffer_index) begin
                        data_out = {(buffer[field_index], buffer[field_index+1]} >> 1 | ((buffer[field_index], buffer[field_index+1]) & 0xf8) << 3;
                        data_out_bin = (buffer[field_index] & 0xF0) << 4 | (buffer[field_index+1] & 0x7F);
                        data_valid = 1;
                    end else {
                        data_valid = 0;
                    }
                end else begin
                    next_state = STATE_IN;
                end
            end

            STATE_OUTPUT: begin
                if (field_index + 1 < buffer_index) begin
                    data_out = {(buffer[field_index], buffer[field_index+1]} >> 1 | ((buffer[field_index], buffer[field_index+1}) & 0xf8) << 3;
                    data_out_bin = (buffer[field_index] & 0xF0) << 4 | (buffer[field_index+1] & 0x7F);
                    data_valid = 1;
                else begin
                    data_valid = 0;
                end
                state = STATE_IN;
            end

            STATE_TIMEOUT: begin
                watchdog_timeout = 1;
                state = STATE_IN;
            end
        endcase
    end

    // Data Output Calculation
    always @(*) begin
        // Check if both characters are hex digits
        reg [6:0] valid_char1, valid_char2;
        valid_char1 = (serial_in >= 8'h00 && serial_in <= 8'h0F);
        valid_char2 = (serial_in >= 8'h00 && serial_in <= 8'h0F);
        
        data_bin_valid = valid_char1 && valid_char2;

        // Convert first two characters to binary value
        data_out = ( (buffer[field_index] >> 1) << 7 ) |
                   ( (buffer[field_index] >> 1) << 6 ) |
                   ( (buffer[field_index] >> 1) << 5 ) |
                   ( (buffer[field_index] >> 1) << 4 ) |
                   ( (buffer[field_index] >> 1) << 3 ) |
                   ( (buffer[field_index] >> 1) << 2 ) |
                   ( (buffer[field_index] >> 1) << 1 ) |
                   ( (buffer[field_index] >> 1) << 0 );
    end

    // Clock and Reset Handling
    localwire clock, reset;
    
    // FSM Control Signals
    localwire [1:0] state, next_state;

    // Internal registers for timing
    reg counter_timeout;
    reg buffer_valid;