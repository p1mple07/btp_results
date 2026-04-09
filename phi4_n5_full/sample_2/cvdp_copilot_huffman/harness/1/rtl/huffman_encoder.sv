module huffman_encoder(
    input  wire        clk,
    input  wire        reset,
    input  wire        data_valid,
    input  wire [3:0]  data_in,
    input  wire [1:0]  data_priority,
    input  wire        update_enable,
    input  wire [3:0]  config_symbol,
    input  wire [6:0]  config_code,
    input  wire [2:0]  config_length,
    output reg [6:0]   huffman_code_out,
    output reg         code_valid,
    output reg         error_flag
);

// Internal signals for Huffman table and code length
wire [6:0] huffman_code;
wire [2:0] code_length;

// Queue outputs from priority queues
wire [3:0] high_queue_out, medium_queue_out, low_queue_out;

// FSM state declaration
localparam [2:0] IDLE       = 3'd0,
                  PREPARE    = 3'd1,
                  CHECK_UPDATE = 3'd2,
                  ENCODE     = 3'd3,
                  OUTPUT     = 3'd4,
                  UPDATE_TABLE = 3'd5,
                  HANDLE_ERROR = 3'd6;

reg [2:0] state;
reg [2:0] next_state;

// Queue pointer and count registers (each queue assumed to have 16 entries)
reg [3:0] high_ptr, medium_ptr, low_ptr;
reg [3:0] high_count, medium_count, low_count;

// Register to hold the current symbol read from the highest priority queue
reg [3:0] current_symbol;

// Register for Huffman table update address
reg [3:0] table_addr;

// Write enable signals for queue RAMs
wire high_we;
wire medium_we;
wire low_we;
assign high_we   = (state == PREPARE) && data_valid && (data_priority == 2'b10);
assign medium_we = (state == PREPARE) && data_valid && (data_priority == 2'b01);
assign low_we    = (state == PREPARE) && data_valid && (data_priority == 2'b00);

// Write enable signals for Huffman table RAMs during update
wire table_we, length_we;
assign table_we  = (state == UPDATE_TABLE);
assign length_we = (state == UPDATE_TABLE);

// Combinational signals to detect non-empty queues
wire read_from_high;
wire read_from_medium;
wire read_from_low;
assign read_from_high   = (state == OUTPUT) && (high_count > 0);
assign read_from_medium = (state == OUTPUT) && (high_count == 0) && (medium_count > 0);
assign read_from_low    = (state == OUTPUT) && (high_count == 0) && (medium_count == 0) && (low_count > 0);

// FSM state register update and output logic
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state           <= IDLE;
        high_ptr        <= 4'd0;
        medium_ptr      <= 4'd0;
        low_ptr         <= 4'd0;
        high_count      <= 4'd0;
        medium_count    <= 4'd0;
        low_count       <= 4'd0;
        current_symbol  <= 4'd0;
        table_addr      <= 4'd0;
        huffman_code_out<= 7'd0;
        code_valid      <= 1'b0;
        error_flag      <= 1'b0;
    end else begin
        // Update pointers and counts on read events
        if (read_from_high) begin
            high_ptr   <= high_ptr + 1;
            high_count <= high_count - 1;
        end else if (read_from_medium) begin
            medium_ptr <= medium_ptr + 1;
            medium_count <= medium_count - 1;
        end else if (read_from_low) begin
            low_ptr    <= low_ptr + 1;
            low_count  <= low_count - 1;
        end

        // Capture current symbol from the appropriate queue
        if (state == OUTPUT) begin
            if (read_from_high)
                current_symbol <= high_queue_out;
            else if (read_from_medium)
                current_symbol <= medium_queue_out;
            else if (read_from_low)
                current_symbol <= low_queue_out;
        end

        // FSM state transitions
        case (state)
            IDLE: begin
                if (update_enable)
                    state <= CHECK_UPDATE;
                else if (data_valid)
                    state <= PREPARE;
                else
                    state <= IDLE;
            end
            PREPARE: begin
                // Data enqueued into the appropriate queue via RAM write
                state <= OUTPUT;
            end
            OUTPUT: begin
                if (read_from_high || read_from_medium || read_from_low)
                    state <= ENCODE;
                else
                    state <= IDLE;
            end
            ENCODE: begin
                // In ENCODE, use current_symbol to read from Huffman table RAMs
                // The outputs are driven in the next clock cycle
                state <= IDLE;
            end
            CHECK_UPDATE: begin
                // Validate update parameters (assumed valid in this example)
                state <= UPDATE_TABLE;
            end
            UPDATE_TABLE: begin
                // Set update address and write new Huffman code and length
                table_addr <= config_symbol;
                state <= IDLE;
            end
            HANDLE_ERROR: begin
                error_flag <= 1'b1;
                // Remain in error state until reset
            end
            default: state <= IDLE;
        endcase
    end
end

// Instantiate priority queue RAMs for High, Medium, and Low priority
single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(4)
) high_queue_ram (
    .clk   (clk),
    .we    (high_we),
    .addr  (high_ptr),
    .din   (data_in),
    .dout  (high_queue_out)
);

single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(4)
) medium_queue_ram (
    .clk   (clk),
    .we    (medium_we),
    .addr  (medium_ptr),
    .din   (data_in),
    .dout  (medium_queue_out)
);

single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(4)
) low_queue_ram (
    .clk   (clk),
    .we    (low_we),
    .addr  (low_ptr),
    .din   (data_in),
    .dout  (low_queue_out)
);

// Instantiate Huffman Table RAM for storing Huffman codes
single_port_ram #(
    .DATA_WIDTH(7),
    .ADDR_WIDTH(4)
) huffman_table_inst (
    .clk   (clk),
    .we    (table_we),
    .addr  (table_addr),
    .din   (config_code),
    .dout  (huffman_code)
);

// Instantiate RAM for storing Huffman code lengths
single_port_ram #(
    .DATA_WIDTH(3),
    .ADDR_WIDTH(4)
) code_length_inst (
    .clk   (clk),
    .we    (length_we),
    .addr  (table_addr),
    .din   (config_length),
    .dout  (code_length)
);

endmodule
