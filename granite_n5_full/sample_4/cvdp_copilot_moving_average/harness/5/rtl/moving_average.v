module moving_average_enhanced(
    input wire clk,
    input wire reset,
    input  wire enable,
    input  wire [11 : 0] data_in,
    output wire [11 : 0] data_out
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2  : 0] write_address;
wire [2 : 0] next_address;
reg [11 : 0] read_data;

// Additional logic to handle enabling and disabling of the module
always @(posedge clk) begin
    if (reset == 1'b1) begin
        for (int i = 0; i < 8; i = i + 1) begin
            memory[i] <= 'h0;
        end
    end else if (enable == 1'b1) begin
        memory[write_address] <= data_in;
    end
end

// Additional logic to handle reading data when enabled
always @(posedge clk) begin
    if (reset == 1'b1) begin
        read_data <= 'h0;
    end else if (enable == 1'b1) begin
        read_data <= memory[next_address];
    end
end

// Additional logic to handle writing address when enabled
always @(posedge clk) begin
    if (reset == 1'b1) begin
        write_address <= 'h0;
    end else if (enable == 1'b1) begin
        write_address <= write_address + 1'b1;
    end
end

// Additional logic to handle sum calculation when enabled
always @(posedge clk) begin
    if (reset == 1'b1) begin
        sum <= 'h0;
    end else if (enable == 1'b1) begin
        sum <= sum + data_in - read_data;
    end
end

// Output logic to calculate the moving average based on the sum and the number of samples
assign data_out = (enable == 1'b1)? (sum >> 3) : 'h0;

endmodule