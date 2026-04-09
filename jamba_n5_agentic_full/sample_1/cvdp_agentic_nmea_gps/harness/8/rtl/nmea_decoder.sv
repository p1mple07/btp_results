module nmea_decoder (
    input wire clk,
    input wire reset,
    input wire [7:0] serial_in,         // ASCII character input
    input wire serial_valid,            // Valid signal for character
    output reg [15:0] data_out,         // Decoded 16-bit output
    output reg data_valid               // Valid signal for output
);

    // FSM states
    localparam STATE_IDLE = 2'b00,
                           STATE_PARSE = 2'b01,
                           STATE_OUTPUT = 2'b10;

    // watchdog counter
    reg [6:0] watchdog_counter;

    // watchdog timeout threshold
    localparam THRESHOLD = 10;

    // buffer and index
    reg [7:0] buffer [0:MAX_BUFFER_SIZE-1];
    reg [6:0] buffer_index;
    reg [6:0] next_buffer_index;
    reg [1:0] state, next_state;
    reg [6:0] comma_count;
    reg [6:0] field_index;

    // watchdog flags
    reg watchdog_timeout_en;

    // internal signals
    wire is_start;
    wire is_comma;
    wire is_end;

    // sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            buffer_index <= 0;
            watchdog_counter <= 0;
            watchdog_timeout_en <= 0;
        end else begin
            state <= next_state;
            buffer_index <= next_buffer_index;

            // read incoming character
            if (serial_valid && is_start) begin
                next_state = STATE_PARSE;
                next_buffer_index = 0;
            end else if (serial_valid) begin
                if (is_end) begin
                    next_state = STATE_OUTPUT;
                end else if (buffer_index < MAX_BUFFER_SIZE-1) begin
                    buffer[next_buffer_index] = serial_in;
                    next_buffer_index = buffer_index + 1;
                end else begin
                    next_state = STATE_IDLE;  // buffer overflow
                    next_buffer_index = 0;
                end
            end

            // combinatorial state transitions
            always @(*) begin
                next_state = state;
                next_buffer_index = buffer_index;
                data_out = 16'b0;
                data_valid = 0;
                comma_count = 0;
                field_index = 0;

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
                                next_state = STATE_IDLE;  // buffer overflow
                                next_buffer_index = 0;
                            end
                        end
                    end

                    STATE_OUTPUT: begin
                        if (buffer[0] == 8'h47 && 
                            buffer[1] == 8'h50 &&
                            buffer[2] == 8'h52 &&
                            buffer[3] == 8'h4D &&
                            buffer[4] == 8'h43) begin
                            // extract numeric field
                            for (i=0; i<MAX_BUFFER_SIZE; i=i+1) begin
                                if (i < buffer_index) begin
                                    if (buffer[i] == 8'h31 && buffer[i+1] == 8'h32) begin
                                        data_out = {buffer[i], buffer[i+1]};
                                        data_valid = 1;
                                    end
                                end
                            end
                        end
                        next_state = STATE_IDLE;
                    end

                    default: next_state = STATE_IDLE;
                endcase
            end
        end
    end

    // watchdog logic
    always @(posedge clk) begin
        if (reset) begin
            watchdog_counter <= 0;
        end else begin
            watchdog_counter <= watchdog_counter - 1;
        end
    end

    assign watchdog_timeout_en = (watchdog_counter < THRESHOLD) ? 1 : 0;

endmodule
