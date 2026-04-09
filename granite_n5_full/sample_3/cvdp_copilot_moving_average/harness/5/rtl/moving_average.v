module moving_average(
    input wire clk,
    input wire rst,
    input  wire en,
    input  wire [11 : 0] data_in,
    output reg [11 : 0] data_out
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2  : 0] write_address;
reg [2  : 0] read_address;
reg [11 : 0] read_data;

// Write current input to memory when enable is high
always @(posedge clk) begin
    if (rst == 1'b1) begin
        for (int i = 0; i < 8; i = i + 1) begin
            memory[i] <= 'h0;
        end
    end else begin
        if (en == 1'b1) begin
            memory[write_address] <= data_in;
        end
    end
end

// Read the oldest element written to memory when enable is high
always @(posedge clk) begin
    if (rst == 1'b1) begin
        read_data <= 'h0;
    end else begin
        if (en == 1'b1) begin
            read_data <= memory[read_address];
        end
    end
end

// Increase write address to move onto the next data when enable is high
always @(posedge clk) begin
    if (rst == 1'b1) begin
        write_address <= 'h0;
    end else begin
        if (en == 1'b1) begin
            write_address <= write_address + 1'b1;
        end
    end
end

// Calculate sum by adding the latest data to the sum and substracting the oldest data when enable is high
always @(posedge clk) begin
    if (rst == 1'b1) begin
        sum <= 'h0;
    end else begin
        if (en == 1'b1) begin
            sum <= sum + data_in - read_data;
        end
    end
end

// Update data_out with the calculated moving average
assign data_out = sum[14 : 3];

endmodule