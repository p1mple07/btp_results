module moving_average(
    input wire clk,
    input wire reset,
    input  wire [11 : 0] data_in,
    output wire [11 : 0] data_out,
    input wire enable
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2  : 0] write_address;
wire [2 : 0] next_address;
reg [11 : 0] read_data;

always @(posedge clk or enable) begin
    if enable = 1'b1 then begin
        memory[write_address] <= data_in;
        read_data <= memory[next_address];
        write_address <= write_address + 1'b1;
        sum <= sum + data_in - read_data;
        data_out = sum[14 : 3];
    end
    else begin
        memory[write_address] <= 'h0;
    end
end

endmodule
