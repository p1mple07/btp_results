module moving_average(
    input wire clk,
    input wire reset,
    input  wire [11 : 0] data_in,
    input wire enable,
    output wire [11 : 0] data_out
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2 : 0] write_address;
wire [2 : 0] next_address;
reg [11 : 0] read_data;

assign next_address = write_address + 1'b1;
assign data_out = sum[14 : 3];

always @(posedge clk or enable) begin
    if (enable == 1'b1) begin
        // Write current data_in to memory
        for (i = 0; i < 8; i = i + 1) begin
            memory[i] <= data_in;
        end

        // Read oldest data from memory
        if (enable) begin
            read_data <= memory[next_address];
        end

        // Update write_address
        if (enable) begin
            write_address <= write_address + 1'b1;
        end

        // Update sum
        if (enable) begin
            sum <= sum + data_in - read_data;
        end
    end

    // Calculate data_out
    assign data_out = sum[14 : 3];
endmodule
