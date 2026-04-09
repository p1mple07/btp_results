module moving_average(
    input wire clk,
    input wire reset,
    input  wire [11 : 0] data_in,
    output wire [11 : 0] data_out
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2:0] write_address;
wire [2:0] next_address;
reg [11:0] read_data;

parameter wire enable;

always @(posedge clk) begin
    if (enable) begin
        // Write new data to memory
        if (write_address < 8) begin
            memory[write_address] <= data_in;
        end
        write_address <= write_address + 1'b1;

        // Read the oldest data
        if (read_data < 12) begin
            read_data <= memory[next_address];
        end

        // Update the running sum
        sum <= sum + data_in - read_data;

        // Compute the output value
        data_out = sum[14:3];
    end
end

endmodule
