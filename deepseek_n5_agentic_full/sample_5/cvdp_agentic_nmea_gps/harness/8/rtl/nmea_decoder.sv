// **State Definitions:**
// State: NORMAL (0) - Waiting for start character '$'.
// State: PROCESSING (1) - Parsing NMEA sentence.
// State: OUTPUT (2) - Extracting and outputting first data field.
// State: IDLE (3) - Ready to receive new NMEA sentence.

// **Configuration**
local param 
    MAX_BUFFER_SIZE = 80;    // Maximum NMEA sentence length
    BIN_WIDTH = 8;             // Width of binary output [8 bits]
    WATCHDOG_TIMEOUT = 200;     // Configurable cycle window for timeout
// **Binary Conversion Logic**
wire [BIN_WIDTH-1:0] data_out_bin;
wire data_bin_valid;

// **State Variables**
reg [7:0] buffer [0:MAX_BUFFER_SIZE-1];          // Sentence buffer
reg [6:0] buffer_index;                          // Current buffer index
reg [6:0] comma_count;                          // Number of comma delimiters
wire [6:0] field_index;                         // Field position tracker
wire [6:0] field_id;                             // Field id tracker
wire [6:0] data_valid;                           // Validity signal for output
wire data_out_valid;                              // Validity signal for output

// **FSM States**
localparam 
    STATE.NORMAL   = 2'b00,
    STATE.PROCESSING  = 2'b01,
    STATE.OUTPUT    = 2'b10,
    STATE.IDLE      = 2'b11;

// **Character Identifiers**
wire is_start = (serial_in == 8'h24);           // '$' character
wire is_comma = (serial_in == 8'h2C);          // ',' character
wire is_end = (serial_in == 8'h0D);            // '\r' character
wire is_digit = (serial_in & 0x0F) != 0;       // Check digit

// **Sequential Logic (Clocked)**
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= STATE.IDLE;
        buffer_index <= 0;
        data_valid <= 0;
        comma_count <= 0;
        field_index <= 0;
        data_out_valid <= 0;
        data_out_bin <= 0;
        data_valid <= 0;
        watchdog_timeout <= 0;
    end else begin
        state <= next_state;
        buffer_index <= next_buffer_index;
        comma_count <= next_comma_count;
        field_index <= next_field_index;
        data_valid <= next_data_valid;
        data_out_valid <= next_data_out_valid;
        data_out_bin <= next_data_out_bin;
        data_valid <= next_data_valid;
        watchdog_timeout <= next_watchdog_timeout;
    end
end

// **Combinational Logic (Clocked)**
always @(*) begin
    next_state = state;
    next_buffer_index = buffer_index;
    next_comma_count = comma_count;
    next_field_index = field_index;
    next_data_valid = data_valid;
    next_data_out_valid = data_out_valid;
    next_data_out_bin = data_out_bin;

    case (state)
        STATE.NORMAL: begin
            if (serial_valid && is_start) begin
                state <= STATE.PROCESSING;
                buffer_index <= 0;
            end else
                state <= STATE.IDLE;
            end
        STATE.PROCESSING: begin
            if (serial_valid) begin
                if (is_end) begin
                    // Parse first field after GPRMC
                    if (buffer[0] == 8'h47 &&
                        buffer[1] == 8'h50 &&
                        buffer[2] == 8'h52 &&
                        buffer[3] == 8'h4D &&
                        buffer[4] == 8'h43) begin
                        // Extract first two characters after GPRMC
                        data_bin_valid = 1;
                        data_out_bin = (buffer[5] << 8') | buffer[6];
                        data_valid = 1;
                    end else begin
                        data_valid = 0;
                    end
                    state <= STATE.IDLE;
                end else if (is_comma) begin
                    comma_count = comma_count + 1;
                    if (comma_count == 1) begin
                        // First data field found
                        field_index = 0;
                    end
                end else begin
                    buffer_index = buffer_index + 1;
                    if (buffer_index > MAX_BUFFER_SIZE - 1) begin
                        // Buffer overflow
                        watchdog_timeout = 1;
                    end
                end
            end
        STATE.OUTPUT: begin
            // Output formatted data
            data_out_valid = 1;
            data_out = data_out_bin;
        STATE.IDLE: begin
            // Idle state
            data_valid = 0;
            data_out_valid = 0;
            data_out = 0;
            watchdog_timeout = 0;
        endcase
    end
end

// **Edge Cases Handling**
always @ (posedge clock) begin
    // Ensure buffer overflow detection
    if (buffer_index >= MAX_BUFFER_SIZE - 1) begin
        watchdog_timeout = 1;
    end
end

// **FSM Transition Timing**
always ensure valid_signal && (!reset || !is_start || !is_comma || !is_end) ;
// **Final FSM Transition Timing**
always ensure valid_signal && (watchdog_timeout_en && !reset) ;
// **FSM Transition Timing (JK Flip-Flop)**
always ensure clocked_signal && !reset ;
// **FSM Transition Timing (FF Delay)**
always ensure clocked_signal && !reset ;
// **FSM Transition Timing (State Outputs)**
always ensure clocked_signal && !reset ;
// **FSM Transition Timing (FSM Control)** 
always ensure clocked_signal && !reset ;
// **FSM Transition Timing (Combinational Logic)** 
always ensure clocked_signal && !reset ;

// **Output Signals**
output reg data_out, data_out_bin, data_valid, data_out_valid;
output reg [15:0] data_out;
output reg data_valid;
output reg [15:0] data_out_bin;
output reg data_out_valid;
output reg watchdow_timeout;
output reg [6:0] watchdow_timeout_en;
// **Input Pins**
input wire [7:0] serial_in;
input wire serial_valid;
input wire reset;
input wire [7:0] watchdow_timeout_en;

// **Clock Signal**
input wire clock;

// **Power-On/Off Reset**
input reg power_on_off;
// **External Characters Input**
input reg [6:0] external_characters;
// **Watchdog Timeout Enabling Signal**
input reg watchdow_timeout_en;
// **Valid Signal for Output Characters**
output reg data_valid;
// **Clock Enable Signal**
input reg clock enable;
// **Characters Identifier**
input reg [6:0] is_start = (external_characters == 8'h24);
input reg [6:0] is_comma = (external_characters == 8'h2C);
input reg [6:0] is_end = (external_characters == 8'h0D);
input reg [6:0] is_digit = (external_characters & 0x0F) != 0;