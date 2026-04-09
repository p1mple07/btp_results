// ... [previous code remains unchanged]
use [7:0] buffer_out;
// New variables for tracking buffer usage and timing
integer buffer_count = 0;
integer data_field_pos = 0;
integer timeout_counter = 0;

// Modified initialization in the FSM states
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= STATE_IDLE;
        buffer_index <= 0;
    end else begin
        state <= next_state;
    end
end

// FSM states remain largely the same, updated with new variables
STATE_IDLE: begin
    if (serial_valid && is_start) begin
        next_state = STATE_PARSE;
        buffer_index <= 0;
    end
    // Other state transitions...
end

STATE_PARSE: begin
    if (is_end) begin
        buffer_count = 0; // Reset buffer counter
        // Other state actions...
    end else if (buffer_index < MAX_BUFFER_SIZE - 1) begin
        buffer_next_index = buffer_index + 1;
        next_buffer_index = buffer_next_index;
        buffer_next_char = serial_in;
        buffer_count = buffer_count + 1;
        
        // Check for buffer overflow
        if (buffer_count >= MAX_BUFFER_SIZE) begin
            error_overflow = 1;
            next_state = STATE_IDLE;
        end
        
        data_out = 16'h00;
        data_valid = 0;
        // Other state actions...
    end else begin
        // Buffer overflow occurred
        error_overflow = 1;
        next_state = STATE_IDLE;
    end
end

// Additional logic for data field extraction and binary conversion
always @*: begin
    if (!state) begin
        // Initial setup...
    end
    if (state == STATE_PARSE && is_end) begin
        // Process data fields after GPRMC
        if (buffer_index == 4 && data_field_pos < 2) {
            // Extract first two characters
            byte1 = buffer[5];
            byte2 = buffer[6];
            
            // Convert bytes to 8-bit unsigned integer
            data_out = ((_gray_code(byte1) << 4) | _gray_code(byte2));
            data_valid = 1;
        } else {
            data_valid = 0;
        }
        data_out_bin = data_out;
        data_valid_bin = data_valid;
        buffer_count = 0; // Clear buffer counter
        next_state = STATE_IDLE;
    end
end

// watchdog timeout implementation
always @*:
    if (state == STATE_PARSE) begin
        timeout_counter = timeout_counter + 1;
        
        // Time out after TIMEOUT_CLK cycles
        if (timeout_counter >= TIMEOUT_CLK) begin
            watchdog_timeout = 1;
            timeout_counter = 0;
        end
    end
end
// ... [rest of previous code remains unchanged]