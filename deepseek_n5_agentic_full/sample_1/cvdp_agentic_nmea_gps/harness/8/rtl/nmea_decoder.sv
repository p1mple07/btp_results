module nmea_decoder (
    input wire [7:0] serial_in,
    input wire serial_valid,
    input wire [1:0] reset_in,
    output reg [15:0] data_out,
    output reg data_valid,
    output reg data_out_bin,
    output reg data_bin_valid,
    output reg[1] watchdog_timeout,
    output reg [6:0] field_index
);

    // FSM States
    state initial_state,
    state parsing_state,
    state timeout_state,
    state output_state;

    // Configuration
    static const MAX_BUFFER_SIZE = 80;
    static const TIMEOUT窗体宽度 = 10;

    // Internal registers
    reg [7:0] buffer [0:MAX_BUFFER_SIZE-1];
    reg [6:0] buffer_index;
    reg [1:0] buffer_full;
    
    // Character identifiers
    wire is_start = (serial_in == 8'h24);
    wire is_comma = (serial_in == 8'h2C);
    wire is_end = (serial_in == 8'h0D);
    wire is_gprmc = (serial_in == 8'h47) & (serial_in == 8'h50) & (serial_in == 8'h52) & (serial_in == 8'h4D) & (serial_in == 8'h43);

    // Binary conversion variables
    reg [15:0] temp_data;
    reg [1:0] bin_valid;
    reg [1:0] num_digits;

    // Error flag
    reg error_overflow = 0;

    // Clocked logic (only combinational due to constraints)
    always @(*) begin
        if (reset_in) begin
            state <= initial_state;
            next_state = initial_state;
            data_out = 0;
            data_valid = 0;
            data_out_bin = 0;
            data_bin_valid = 0;
            buffer_index = 0;
            buffer_full = 0;
        end else begin
            next_state = state;
        end
    end

    // Combinational logic
    always @(*) begin
        // FSM State Machine
        case(state)
            initial_state: begin
                if (serial_valid && is_start) begin
                    state <= parsing_state;
                    next_state = parsing_state;
                end
            end

            parsing_state: begin
                if (serial_valid) begin
                    if (is_gprmc) begin
                        // Start of GPRMC sentence
                        field_index <= 6;
                        next_state = timeout_state;
                        next_buffer_index = 0;
                        buffer_full = 0;
                        bin_valid = 0;
                        num_digits = 0;
                    end else begin
                        next_buffer_index <= buffer_index + 1;
                        next_buffer_index = min(next_buffer_index + 1, MAX_BUFFER_SIZE - 1);
                        buffer[next_buffer_index] = serial_in;
                        next_buffer_index = buffer_index + 1;
                    end
                end
            end

            timeout_state: begin
                if (!watchdog_timeout_en) begin
                    if (clock) begin
                        // Timer increment
                        timeout_state <= output_state;
                        clock = 0;
                    end
                end
            end

            output_state: begin
                if (field_index >= 6 || !bin_valid) begin
                    data_out = 0;
                    data_valid = 0;
                    data_out_bin = 0;
                    data_bin_valid = 0;
                else if (bin_valid && field_index < 6) begin
                    // Convert first two digits to binary
                    temp_data = 0;
                    num_digits = 0;
                    
                    for (int i = 0; i < 2; i++) {
                        if (field_index >= 2*i && field_index >= 2*i + 1 &&
                            (field_index >= 2*i || field_index >= 2*i + 1)) begin
                            temp_data <<= 1;
                            if (field_index >= 2*i + 1) begin
                                temp_data |= (field[index] & 0x1F);
                                num_digits++;
                            end
                        end
                    }
                    
                    data_out = temp_data;
                    data_valid = 1;
                    data_out_bin = temp_data;
                    data_bin_valid = 1;
                end
                next_state = initial_state;
            end
        endcase
    end

    // Character identifiers
    always @(*) begin
        next_buffer_index = buffer_index;
        next_buffer_index = min(next_buffer_index + 1, MAX_BUFFER_SIZE - 1);
    end

    // Register assignments
    assign next_state = state;
    assign data_out = data_out;
    assign data_valid = data_valid;
    assign data_out_bin = data_out_bin;
    assign data_bin_valid = data_bin_valid;
    assign buffer_index = buffer_index;
    assign buffer_full = buffer_full;
    assign next_buffer_index = next_buffer_index;