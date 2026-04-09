module moving_average(
    input wire clk,
    input wire reset,
    input wire enable,
    input  wire [11:0] data_in,
    output wire [11:0] data_out
);

reg [11:0] memory [7:0];
reg [14:0] sum;
reg [2:0] write_address;
wire [2:0] next_address;
reg [11:0] read_data;

assign next_address = write_address + 1'b1;
assign data_out = sum[14:3];

// Write current input to memory
integer i;
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 8; i = i + 1) begin
            memory[i] <= 12'b0;
        end
    end else if (enable) begin
        memory[write_address] <= data_in;
    end
end

// Read the oldest element written to memory
always @(posedge clk) begin
    if (reset) begin
        read_data <= 12'b0;
    end else if (enable) begin
        read_data <= memory[next_address];
    end
end

// Increase the write address to move onto the next data
always @(posedge clk) begin
    if (reset) begin
        write_address <= 3'b0;
    end else if (enable) begin
        write_address <= write_address + 1'b1;
    end
end

// Calculate sum by adding the latest data and subtracting the oldest data
always @(posedge clk) begin
    if (reset) begin
        sum <= 15'b0;
    end else if (enable) begin
        sum <= sum + data_in - read_data;
    end
end

endmodule