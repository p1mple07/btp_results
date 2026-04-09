// Enhanced nmea_decoder with binary conversion, watchdog, and overflow protection
module nmea_decoder (
    input wire clk,
    input wire reset,
    input wire [7:0] serial_in,         // ASCII character input
    input wire serial_valid,            // Valid signal for character
    output reg [15:0] data_out,         // Extracted data field (8‑bit binary)
    output reg data_valid,              // Valid signal for output
    output reg data_out_bin,            // 8‑bit binary representation
    output reg data_bin_valid,          // Data conversion success
    output reg error_overflow,          // Buffer overflow flag
    output reg watchdog_timeout,        // Timeout flag
    output reg [15:0] data_out_bin_bin, // Alternative 16‑bit output for debugging
    output reg data_out_bin_bin_valid   // Debug output for binary
);

    localparam MAX_BUFFER_SIZE = 80;
    integer i;

    reg [7:0] buffer [0:MAX_BUFFER_SIZE-1];
    reg [6:0] buffer_index;
    reg [6:0] next_buffer_index;
    reg [1:0] state, next_state;
    reg [6:0] comma_count;
    reg [6:0] field_index;
    reg [7:0] field_value;
    reg data_bin_valid;
    reg watchdog_timeout;
    reg [15:0] data_out_bin_bin;
    reg data_out_bin_bin_valid;

    // FSM states
    localparam STATE_IDLE   = 2'b00,
                          STATE_PARSE  = 2'b01,
                          STATE_OUTPUT = 2'b10;

    // Counters and flags
    reg [15:0] buffer_length;
    reg [1:0] buffer_full;
    reg [6:0] watch_cnt;

    // Sentinel for buffer overflow
    wire overflow_flag;

    // Internal signals
    wire is_start = (serial_in == 8'h24);
    wire is_comma = (serial_in == 8'h2C);
    wire is_end   = (serial_in == 8'h0D);

    // Initial state setup
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            buffer_index <= 0;
            buffer[0] <= 8'd0;
            field_value <= 0;
            data_valid <= 0;
            data_out_bin_bin <= 0;
            data_out_bin_bin_valid <= 0;
            watch_cnt <= 0;
        end else begin
            state <= next_state;
            buffer_index <= next_buffer_index;
        end
    end

    // Combinational logic
    always @(*) begin
        next_state = state;
        next_buffer_index = buffer_index;
        data_out_bin_bin = 8'd0;
        data_out_bin_bin_valid = 0;
        field_value <= 0;
        data_valid <= 0;
        data_out <= 16'b0;
        data_valid <= 0;
        comma_count <= 0;
        field_index <= 0;
        buffer_full <= 0;
        buffer_length <= 0;
        overflow_flag <= 0;
        watch_cnt <= 0;

        case (state)
            STATE_IDLE: begin
                if (serial_valid && is_start) begin
                    next_state = STATE_PARSE;
                    next_buffer_index = 0;
                end
            end

            STATE_PARSE: begin
                if (serial_valid) begin
                    if (is_end) begin
                        next_state = STATE_OUTPUT;
                    end else if (buffer_index < MAX_BUFFER_SIZE-1) begin
                        buffer[next_buffer_index] = serial_in;
                        next_buffer_index = buffer_index + 1;
                    end else begin
                        next_state = STATE_IDLE;  // Buffer overflow
                        next_buffer_index = 0;
                    end
                end
            end

            STATE_OUTPUT: begin
                if (buffer[0] == 8'h47 && 
                    buffer[1] == 8'h50 &&
                    buffer[2] == 8'h52 &&
                    buffer[3] == 8'h4D &&
                    buffer[4] == 8'h43 &&
                    buffer[5] == 8'h2C) begin
                    for (i = 0; i < MAX_BUFFER_SIZE; i = i + 1) begin
                        if (i < buffer_index) begin
                            if (buffer[i] == 8'h2C) begin
                                comma_count = comma_count + 1;
                                if (comma_count == 1) begin
                                    field_index = i + 1;  // First data field
                                end
                            end
                        end
                    end

                    if (field_index+1 < buffer_index) begin
                        // Convert the 2-byte field to binary
                        field_value = buffer[field_index];
                        field_value = field_value << 8;
                        field_value = field_value + buffer[field_index+1];
                        field_value = field_value & 0xFFF;
                        data_out_bin = data_out_bin_bin;
                        data_out_bin_valid = 1;
                    end
                end
                next_state = STATE_IDLE;  
            end

            default: next_state = STATE_IDLE;
        endcase
    end

    // Watchdog
    always @(posedge clk) begin
        if (~watchdog_timeout) begin
            watchdog_timeout <= 1;
        end else begin
            watchdog_timeout <= 0;
        end
    end

    // Overflow detection
    assign overflow_flag = buffer_length > MAX_BUFFER_SIZE;

    // Final output
    assign data_out = field_value;
    assign data_valid = data_out_bin_valid;
    assign data_out_bin = data_out_bin_bin;
    assign data_out_bin_valid = data_out_bin_bin_valid;
    assign error_overflow = overflow_flag;
    assign watchdog_timeout = watchdog_timeout;

endmodule
