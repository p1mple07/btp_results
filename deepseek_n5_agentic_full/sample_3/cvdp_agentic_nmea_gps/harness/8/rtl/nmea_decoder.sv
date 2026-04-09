module code remains unchanged] ...

    // Configuration
    integer i;
    
    // Module internals
    reg [7:0] buffer [0:MAX_BUFFER_SIZE-1];
    reg [6:0] buffer_index;
    reg [1:0] state, next_state;
    reg [6:0] comma_count, field_index;
    reg [6:0] buffer_valid;
    reg [1:0] state, next_state;

    // Characters
    wire is_start = (buffer[0] == 8'h24);
    wire is_comma = (buffer[1] == 8'h2C);  // ','
    wire is_end = (buffer[2] == 8'h0D);    // '\r'

    // Sequential logic (clocked)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            buffer_index <= 0;
        end else begin
            state <= next_state;
            buffer_index <= next_buffer_index;
        end
    end

    // Combinational logic
    always @(*) begin
        next_state = state;
        next_buffer_index = buffer_index;
        data_out = 0;
        data_valid = 0;
        comma_count = 0;
        field_index = 0;

        case (state)
            STATE_IDLE: begin
                if (is_start && is_comma) begin
                    for (i=0; i<MAX_BUFFER_SIZE-1; i=i+1) {
                        if (is_end) begin
                            next_state = STATE_OUTPUT;
                        end else if (buffer_index < MAX_BUFFER_SIZE-1) begin
                            buffer[next_buffer_index] = buffer[index];
                            next_buffer_index = buffer_index + 1;
                        end else begin
                            next_state = STATE_IDLE;
                            next_buffer_index = 0;
                        end
                    }
                    if (field_index >= 0) begin
                        data_out = (buffer[field_index] << 1) | buffer[field_index + 1];
                        data_bin_valid = 1;
                    end
                    next_state = STATE_OUTPUT;
                end
                next_state = STATE_IDLE;
                buffer_index = 0;
            end

            // Other state cases remain unchanged

            default: next_state = STATE_IDLE;
        endcase
    end

endmodule