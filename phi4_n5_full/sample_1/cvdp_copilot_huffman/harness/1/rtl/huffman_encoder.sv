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

// Internal state encoding
localparam IDLE           = 3'd0,
           PREPARE        = 3'd1,
           CHECK_UPDATE   = 3'd2,
           UPDATE_TABLE   = 3'd3,
           ENCODE         = 3'd4,
           OUTPUT         = 3'd5,
           HANDLE_ERROR   = 3'd6;

// FSM state register
reg [2:0] state;

// Queue pointers for three priority levels
reg [1:0] high_queue_read, high_queue_write;
reg [1:0] medium_queue_read, medium_queue_write;
reg [1:0] low_queue_read, low_queue_write;

// Internal signals for queue RAM control
reg high_queue_we;
reg [1:0] high_queue_addr;
reg [3:0] high_queue_din;

reg medium_queue_we;
reg [1:0] medium_queue_addr;
reg [3:0] medium_queue_din;

reg low_queue_we;
reg [1:0] low_queue_addr;
reg [3:0] low_queue_din;

// Internal signals for Huffman table update
reg huff_code_we;
reg [3:0] huff_code_addr;
reg [6:0] huff_code_din;

reg code_len_we;
reg [3:0] code_len_addr;
reg [2:0] code_len_din;

// Wire to capture symbol read from queue
reg [3:0] symbol;

// Wires from RAM instantiations
wire [3:0] high_queue_data, medium_queue_data, low_queue_data;
wire [6:0] huffman_code_table;
wire [2:0] code_length_table;

// Instantiate priority queues (each with 4 entries)
// High Priority Queue
single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(2)
) high_queue_ram_inst (
    .clk(clk),
    .we(high_queue_we),
    .addr(high_queue_addr),
    .din(high_queue_din),
    .dout(high_queue_data)
);

// Medium Priority Queue
single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(2)
) medium_queue_ram_inst (
    .clk(clk),
    .we(medium_queue_we),
    .addr(medium_queue_addr),
    .din(medium_queue_din),
    .dout(medium_queue_data)
);

// Low Priority Queue
single_port_ram #(
    .DATA_WIDTH(4),
    .ADDR_WIDTH(2)
) low_queue_ram_inst (
    .clk(clk),
    .we(low_queue_we),
    .addr(low_queue_addr),
    .din(low_queue_din),
    .dout(low_queue_data)
);

// Instantiate Huffman Table RAMs
// Huffman Code RAM (7-bit codes, 16 entries)
single_port_ram #(
    .DATA_WIDTH(7),
    .ADDR_WIDTH(4)
) huffman_code_ram_inst (
    .clk(clk),
    .we(huff_code_we),
    .addr(huff_code_addr),
    .din(huff_code_din),
    .dout(huffman_code_table)
);

// Code Length RAM (3-bit lengths, 16 entries)
single_port_ram #(
    .DATA_WIDTH(3),
    .ADDR_WIDTH(4)
) code_length_ram_inst (
    .clk(clk),
    .we(code_len_we),
    .addr(code_len_addr),
    .din(code_len_din),
    .dout(code_length_table)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state           <= IDLE;
        high_queue_read <= 2'd0;
        high_queue_write<= 2'd0;
        medium_queue_read<= 2'd0;
        medium_queue_write<= 2'd0;
        low_queue_read   <= 2'd0;
        low_queue_write  <= 2'd0;
        error_flag       <= 1'b0;
        code_valid       <= 1'b0;
        huffman_code_out <= 7'd0;
        // Clear RAM control signals
        high_queue_we    <= 1'b0;
        medium_queue_we  <= 1'b0;
        low_queue_we     <= 1'b0;
        huff_code_we     <= 1'b0;
        code_len_we      <= 1'b0;
    end else begin
        // Default assignments for RAM control signals
        high_queue_we    <= 1'b0;
        high_queue_addr  <= high_queue_write;
        high_queue_din   <= data_in;
        medium_queue_we  <= 1'b0;
        medium_queue_addr<= medium_queue_write;
        medium_queue_din <= data_in;
        low_queue_we     <= 1'b0;
        low_queue_addr   <= low_queue_write;
        low_queue_din    <= data_in;
        huff_code_we     <= 1'b0;
        huff_code_addr   <= config_symbol;
        huff_code_din    <= config_code;
        code_len_we      <= 1'b0;
        code_len_addr    <= config_symbol;
        code_len_din     <= config_length;

        case (state)
            IDLE: begin
                error_flag <= 1'b0;
                code_valid <= 1'b0;
                if (data_valid) begin
                    case (data_priority)
                        2'b11: begin
                            high_queue_we    <= 1'b1;
                            high_queue_addr  <= high_queue_write;
                            high_queue_din   <= data_in;
                            high_queue_write <= high_queue_write + 1'b1;
                        end
                        2'b10: begin
                            medium_queue_we  <= 1'b1;
                            medium_queue_addr<= medium_queue_write;
                            medium_queue_din <= data_in;
                            medium_queue_write<= medium_queue_write + 1'b1;
                        end
                        default: begin
                            low_queue_we     <= 1'b1;
                            low_queue_addr   <= low_queue_write;
                            low_queue_din    <= data_in;
                            low_queue_write  <= low_queue_write + 1'b1;
                        end
                    endcase
                    state <= PREPARE;
                end else if (update_enable) begin
                    state <= CHECK_UPDATE;
                end else begin
                    state <= IDLE;
                end
            end

            PREPARE: begin
                if (update_enable) begin
                    state <= CHECK_UPDATE;
                end else begin
                    state <= ENCODE;
                end
            end

            CHECK_UPDATE: begin
                if (config_length > 6) begin
                    error_flag <= 1'b1;
                    state <= HANDLE_ERROR;
                end else begin
                    state <= UPDATE_TABLE;
                end
            end

            UPDATE_TABLE: begin
                huff_code_we     <= 1'b1;
                code_len_we      <= 1'b1;
                state <= IDLE;
            end

            ENCODE: begin
                // Check high priority queue first
                if (high_queue_read != high_queue_write) begin
                    high_queue_addr <= high_queue_read;
                    symbol          <= high_queue_data;
                    high_queue_read <= high_queue_read + 1'b1;
                    state <= OUTPUT;
                end else if (medium_queue_read != medium_queue_write) begin
                    medium_queue_addr <= medium_queue_read;
                    symbol           <= medium_queue_data;
                    medium_queue_read<= medium_queue_read + 1'b1;
                    state <= OUTPUT;
                end else if (low_queue_read != low_queue_write) begin
                    low_queue_addr   <= low_queue_read;
                    symbol           <= low_queue_data;
                    low_queue_read   <= low_queue_read + 1'b1;
                    state <= OUTPUT;
                end else begin
                    state <= ENCODE;
                end
            end

            OUTPUT: begin
                // Read Huffman code and length from table using the symbol
                huff_code_addr <= symbol;
                huffman_code_out <= huffman_code_table;
                code_valid <= 1'b1;
                state <= IDLE;
            end

            HANDLE_ERROR: begin
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule

// RTL Code for single_port_ram
module single_port_ram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire we,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

// Memory array
reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            mem[i] <= {DATA_WIDTH{1'b0}};
        end
    end else if (we) begin
        mem[addr] <= din;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        dout <= {DATA_WIDTH{1'b0}};
    end else begin
        dout <= mem[addr];
    end
end

endmodule