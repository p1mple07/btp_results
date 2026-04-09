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

    // FSM States
    localparam [2:0]
        IDLE         = 3'd0,
        PREPARE      = 3'd1,
        CHECK_UPDATE = 3'd2,
        ENCODE       = 3'd3,
        OUTPUT       = 3'd4,
        HANDLE_ERROR = 3'd5,
        UPDATE_TABLE = 3'd6;
    
    reg [2:0] state;
    
    // Signals for RAM writes
    reg we_table, we_code_length;
    reg we_queue_high, we_queue_medium, we_queue_low;
    
    // Data for RAM writes
    reg [6:0] table_din;
    reg [2:0] code_length_din;
    reg [3:0] queue_high_din, queue_medium_din, queue_low_din;
    
    // Queue counters
    reg [3:0] queue_high_counter;
    reg [3:0] queue_medium_counter;
    reg [3:0] queue_low_counter;
    
    // Queue addresses assignments
    wire [3:0] queue_high_addr = queue_high_counter;
    wire [3:0] queue_medium_addr = queue_medium_counter;
    wire [3:0] queue_low_addr = queue_low_counter;
    
    // Wires from RAMs
    wire [6:0] huffman_code;
    wire [2:0] code_length;
    wire [3:0] queue_high_out, queue_medium_out, queue_low_out;
    
    // Instantiate Huffman Table RAM
    single_port_ram #(
        .DATA_WIDTH(7),
        .ADDR_WIDTH(4)
    ) huff_table (
        .clk(clk),
        .we(we_table),
        .addr(data_in),
        .din(table_din),
        .dout(huffman_code)
    );
    
    // Instantiate Code Length RAM
    single_port_ram #(
        .DATA_WIDTH(3),
        .ADDR_WIDTH(4)
    ) code_length_ram (
        .clk(clk),
        .we(we_code_length),
        .addr(data_in),
        .din(code_length_din),
        .dout(code_length)
    );
    
    // Instantiate Priority Queue RAMs
    single_port_ram #(
        .DATA_WIDTH(4),
        .ADDR_WIDTH(4)
    ) queue_high (
        .clk(clk),
        .we(we_queue_high),
        .addr(queue_high_addr),
        .din(queue_high_din),
        .dout(queue_high_out)
    );
    
    single_port_ram #(
        .DATA_WIDTH(4),
        .ADDR_WIDTH(4)
    ) queue_medium (
        .clk(clk),
        .we(we_queue_medium),
        .addr(queue_medium_addr),
        .din(queue_medium_din),
        .dout(queue_medium_out)
    );
    
    single_port_ram #(
        .DATA_WIDTH(4),
        .ADDR_WIDTH(4)
    ) queue_low (
        .clk(clk),
        .we(we_queue_low),
        .addr(queue_low_addr),
        .din(queue_low_din),
        .dout(queue_low_out)
    );
    
    // FSM Sequential Logic
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            code_valid <= 1'b0;
            error_flag <= 1'b0;
            we_table <= 1'b0;
            we_code_length <= 1'b0;
            we_queue_high <= 1'b0;
            we_queue_medium <= 1'b0;
            we_queue_low <= 1'b0;
            queue_high_counter <= 4'd0;
            queue_medium_counter <= 4'd0;
            queue_low_counter <= 4'd0;
            table_din <= 7'd0;
            code_length_din <= 3'd0;
            queue_high_din <= 4'd0;
            queue_medium_din <= 4'd0;
            queue_low_din <= 4'd0;
        end else begin
            case(state)
                IDLE: begin
                    if(data_valid) begin
                        if(update_enable)
                            state <= UPDATE_TABLE;
                        else
                            state <= PREPARE;
                    end
                end
                PREPARE: begin
                    state <= ENCODE;
                end
                ENCODE: begin
                    huffman_code_out <= huffman_code;
                    code_valid <= 1'b1;
                    state <= OUTPUT;
                end
                OUTPUT: begin
                    state <= IDLE;
                end
                UPDATE_TABLE: begin
                    table_din <= config_code;
                    code_length_din <= config_length;
                    we_table <= 1'b1;
                    we_code_length <= 1'b1;
                    state <= CHECK_UPDATE;
                end
                CHECK_UPDATE: begin
                    if(config_length == 3'd0)
                        error_flag <= 1'b1;
                    else
                        error_flag <= 1'b0;
                    we_table <= 1'b0;
                    we_code_length <= 1'b0;
                    state <= IDLE;
                end
                HANDLE_ERROR: begin
                    error_flag <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    // Combinational logic for priority queue writes
    always @(*) begin
        we_queue_high = 1'b0;
        we_queue_medium = 1'b0;
        we_queue_low = 1'b0;
        queue_high_din = 4'd0;
        queue_medium_din = 4'd0;
        queue_low_din = 4'd0;
        case(data_priority)
            2'b11: begin
                we_queue_high = data_valid;
                queue_high_din = data_in;
            end
            2'b10: begin
                we_queue_medium = data_valid;
                queue_medium_din = data_in;
            end
            2'b01: begin
                we_queue_low = data_valid;
                queue_low_din = data_in;
            end
            default: begin
                // No queue write for other priorities
            end
        endcase
    end

endmodule