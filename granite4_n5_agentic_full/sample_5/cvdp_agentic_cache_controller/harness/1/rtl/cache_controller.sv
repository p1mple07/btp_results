module cache_controller (
    input wire clk,
    input wire reset,
    input wire [4:0] address,
    input wire write,
    input wire read,
    output reg hit,
    output reg miss,
    output reg [31:0] read_data,
    output reg mem_write,
    output reg [31:0] mem_address,
    output reg [31:0] mem_write_data,
    input wire [31:0] mem_read_data,
    input wire mem_ready
);

// Cache memory
reg [31:0] cache[0:31];
reg [4:0] cache_tag[0:31];
reg [31:0] cache_write_data[0:31];
reg [4:0] cache_address[0:31];
reg [31:0] cache_read_data[0:31];
reg [31:0] cache_write_back_data[0:31];
reg [1:0] cache_state[0:31];

// Reset logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (int i = 0; i < 32; i++) begin
            cache[i] <= 32'b0;
            cache_tag[i] <= 5'b0;
            cache_write_data[i] <= 32'b0;
            cache_address[i] <= 5'b0;
            cache_read_data[i] <= 32'b0;
            cache_write_back_data[i] <= 32'b0;
            cache_state[i] <= 2'b00;
        end
    end
end

// Address generation logic
assign cache_address = address + 'h1000;

// Read operation
always @(posedge clk) begin
    if (read) begin
        for (int i = 0; i < 32; i++) begin
            if ((cache_tag[i] == address) && (cache_state[i] == 2'b00)) begin
                read_data <= cache_read_data[i];
                hit <= 1'b1;
                miss <= 1'b0;
                break;
            end
        end
    end
end

// Write operation (write-through policy)
always @(posedge clk) begin
    if (write) begin
        for (int i = 0; i < 32; i++) begin
            if ((cache_tag[i] == address) && (cache_state[i] == 2'b00)) begin
                cache_write_data[i] <= write_data;
                cache_state[i] <= 2'b10;
                break;
            end
        end
        mem_address <= address;
        mem_write <= 1;
        mem_write_data <= write_data;
        mem_ready <= 1;
    end
end

// Main memory interface
always @(posedge clk) begin
    if (mem_ready) begin
        cache_write_back_data[address] <= mem_read_data;
        cache_state[address] <= 2'b01;
        miss <= 1'b0;
    end
end

endmodule