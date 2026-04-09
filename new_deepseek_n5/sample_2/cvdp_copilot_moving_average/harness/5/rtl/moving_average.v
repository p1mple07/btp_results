module moving_average(
    input wire clk,
    input wire reset,
    input wire [11:0] data_in,
    input wire enable,
    output wire [11:0] data_out
);

reg [11:0] memory [7:0];
reg [14:0] sum;
reg [2:0] write_address;
wire [2:0] next_address;
reg [11:0] read_data;

always @(posedge clk, enable) begin
    if (reset == 1'b1) begin
        memory[0:7] = 'h0;
        sum = 'h0;
        write_address = 'h0;
        read_data = 'h0;
    end else begin
        if (enable == 1'b1) begin
            memory[write_address] <= data_in;
            sum <= sum + data_in - read_data;
            write_address <= write_address + 1'b1;
        end
        read_data <= memory[next_address];
    end
end

data_out = sum[14:3];
endmodule