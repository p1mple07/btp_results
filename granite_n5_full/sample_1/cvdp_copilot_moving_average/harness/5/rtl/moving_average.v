module moving_average (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [11 : 0] data_in,
    output reg [11 : 0] data_out
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2  : 0] write_address;
wire [2 : 0] next_address;
wire [11 : 0] read_data;

// Write current input to memory when enable is high
always @ (posedge clk) begin
    if (reset == 1'b1) begin
        for (int i = 0; i < 8; i = i + 1) begin
            memory[i] <= 'h0;
        end
    end
    else if (enable == 1'b1) begin
        memory[write_address] <= data_in;
    end
end

// Read the oldest element written to memory when enable is high
always @ (posedge clk) begin
    if (reset == 1'b1) begin
        read_data <= 'h0;
    end
    else if (enable == 1'b1) begin
        read_data <= memory[next_address];
    end
end

// Increase the write address to move onto the next data when enable is high
always @ (posedge clk) begin
    if (reset == 1'b1) begin
        write_address <= 'h0;
    end
    else if (enable == 1'b1) begin
        write_address <= write_address + 1'b1;
    end
end

// Calculate sum by adding the latest data to the sum and substracting the oldest data when enable is high
always @ (posedge clk) begin
    if (reset == 1'b1) begin
        sum <= 'h0;
    end
    else if (enable == 1'b1) begin
        sum <= sum + data_in - read_data;
    end
end

// Calculate the moving average by dividing the sum by the number of samples
assign data_out = (sum >> 3) 'd0;

endmodule