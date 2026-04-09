module huffman_encoder(
    input wire clk,
    input wire reset,
    input wire data_valid,
    input wire [3:0] data_in,
    input wire [1:0] data_priority,
    input wire update_enable,
    input wire [3:0] config_symbol,
    input wire [6:0] config_code,
    input wire [2:0] config_length,
    output reg [6:0] huffman_code_out,
    output reg code_valid,
    output reg error_flag
);

// FSM state definitions
parameter IDLE           = 3'd0,
          PREPARE        = 3'd1,
          CHECK_UPDATE   = 3'd2,
          UPDATE_TABLE   = 3'd3,
          ENCODE         = 3'd4,
          OUTPUT         = 3'd5,
          HANDLE_ERROR   = 3'd6;

// State register
reg [2:0] state, next_state;

// Queue pointers
reg [3:0] high_ptr, medium_ptr, low_ptr;

// Queue selection and data registers
reg [3:0] queue_data;
reg [3:0] queue_ptr;
reg [1:0] queue_sel; // 00: high, 01: medium, 10: low

// Signals for queue RAM writes
reg queue_high_we, queue_medium_we, queue_low_we;
reg [3:0] queue_high_addr, queue_medium_addr, queue_low_addr;
reg [3:0] queue_high_din, queue_medium_din, queue_low_din;

// Signals for Huffman table RAM writes
reg we_table, we_length;
reg [3:0] addr_table, addr_length;
reg [6:0] table_din;
reg [2:0] length_din;

// Wires for RAM outputs
wire [3:0] queue_high_out, queue_medium_out, queue_low_out;
wire [6:0] huffman_code;
wire [2:0] code_length;

// Instantiate queue RAMs (for priority queues)
// Queue RAMs use 4-bit data width and 4-bit address width
single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(4)
) queue_high_inst (
    .clk(clk),
    .we(queue_high_we),
    .addr(queue_high_addr),
    .din(queue_high_din),
    .dout(queue_high_out)
);

single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(4)
) queue_medium_inst (
    .clk(clk),
    .we(queue_medium_we),
    .addr(queue_medium_addr),
    .din(queue_medium_din),
    .dout(queue_medium_out)
);

single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(4)
) queue_low_inst (
    .clk(clk),
    .we(queue_low_we),
    .addr(queue_low_addr),
    .din(queue_low_din),
    .dout(queue_low_out)
);

// Instantiate Huffman table RAM
single_port_ram #(
    .DATA_WIDTH(7),
    .ADDR_WIDTH(4)
) huffman_table_inst (
    .clk(clk),
    .we(we_table),
    .addr(addr_table),
    .din(table_din),
    .dout(huffman_code)
);

// Instantiate code length RAM
single_port_ram #(
    .DATA_WIDTH(3),
    .ADDR_WIDTH(4)
) code_length_table_inst (
    .clk(clk),
    .we(we_length),
    .addr(addr_length),
    .din(length_din),
    .dout(code_length)
);

// FSM sequential logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state         <= IDLE;
        high_ptr      <= 4'd0;
        medium_ptr    <= 4'd0;
        low_ptr       <= 4'd0;
        code_valid    <= 0;
        error_flag    <= 0;
        // Clear all write enables
        queue_high_we <= 0;
        queue_medium_we <= 0;
        queue_low_we   <= 0;
        we_table       <= 0;
        we_length      <= 0;
    end else begin
        state <= next_state;
        // Default assignments
        queue_high_we <= 0;
        queue_medium_we <= 0;
        queue_low_we   <= 0;
        we_table       <= 0;
        we_length      <= 0;
        code_valid     <= 0;

        case (state)
            IDLE: begin
                if (update_enable) begin
                    next_state <= PREPARE;
                end else if (data_valid) begin
                    next_state <= PREPARE;
                    // Enqueue incoming data based on priority
                    case (data_priority)
                        2'b00: begin
                            queue_high_we   <= 1;
                            queue_high_addr <= high_ptr;
                            queue_high_din  <= data_in;
                            high_ptr        <= high_ptr + 1;
                        end
                        2'b01: begin
                            queue_medium_we <= 1;
                            queue_medium_addr <= medium_ptr;
                            queue_medium_din  <= data_in;
                            medium_ptr        <= medium_ptr + 1;
                        end
                        2'b10: begin
                            queue_low_we   <= 1;
                            queue_low_addr <= low_ptr;
                            queue_low_din  <= data_in;
                            low_ptr        <= low_ptr + 1;
                        end
                        default: next_state <= IDLE;
                    endcase
                end else begin
                    next_state <= IDLE;
                end
            end

            PREPARE: begin
                if (update_enable) begin
                    next_state <= CHECK_UPDATE;
                end else if (data_valid) begin
                    next_state <= ENCODE;
                end else begin
                    next_state <= IDLE;
                end
            end

            CHECK_UPDATE: begin
                if (config_length == 3'd0) begin
                    error_flag <= 1;
                    next_state <= HANDLE_ERROR;
                end else begin
                    next_state <= UPDATE_TABLE;
                end
            end

            UPDATE_TABLE: begin
                // Update Huffman table and code length table
                we_table      <= 1;
                addr_table    <= config_symbol;
                table_din     <= config_code;
                we_length     <= 1;
                addr_length   <= config_symbol;
                length_din    <= config_length;
                next_state    <= OUTPUT;
            end

            ENCODE: begin
                // Select the highest priority non-empty queue
                if (high_ptr != 4'd0) begin
                    queue_sel  <= 2'b00;
                    queue_ptr  <= high_ptr;
                    queue_data <= queue_high_out;
                end else if (medium_ptr != 4'd0) begin
                    queue_sel  <= 2'b01;
                    queue_ptr  <= medium_ptr;
                    queue_data <= queue_medium_out;
                end else if (low_ptr != 4'd0) begin
                    queue_sel  <= 2'b10;
                    queue_ptr  <= low_ptr;
                    queue_data <= queue_low_out;
                end else begin
                    error_flag <= 1;
                    next_state <= HANDLE_ERROR;
                end
                next_state <= OUTPUT;
            end

            OUTPUT: begin
                // Read Huffman code from table using the dequeued symbol
                addr_table <= queue_data;
                // Clear the dequeued entry in the corresponding queue
                if (queue_sel == 2'b00) begin
                    queue_high_we   <= 1;
                    queue_high_addr <= queue_ptr;
                    queue_high_din  <= 4'd0;
                    high_ptr        <= high_ptr + 1;
                end else if (queue_sel == 2'b01) begin
                    queue_medium_we <= 1;
                    queue_medium_addr <= queue_ptr;
                    queue_medium_din  <= 4'd0;
                    medium_ptr        <= medium_ptr + 1;
                end else if (queue_sel == 2'b10) begin
                    queue_low_we   <= 1;
                    queue_low_addr <= queue_ptr;
                    queue_low_din  <= 4'd0;
                    low_ptr        <= low_ptr + 1;
                end
                // Output the Huffman code (note: huffman_code is registered)
                huffman_code_out <= huffman_code;
                code_valid       <= 1;
                next_state       <= IDLE;
            end

            HANDLE_ERROR: begin
                error_flag <= 1;
                code_valid <= 0;
                next_state <= HANDLE_ERROR; // Remain in error state until reset
            end

            default: next_state <= IDLE;
        endcase
    end
end

endmodule

