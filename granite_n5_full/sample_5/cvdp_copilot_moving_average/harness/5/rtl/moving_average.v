module moving_average(
    input wire clk,
    input wire reset,
    input  wire [11 : 0] data_in,
    input  wire         enable,
    output wire [11 : 0] data_out
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2  : 0] write_address;
reg [11 : 0] read_data;

always @ (posedge clk) begin
    if (reset == 1'b1) begin
        for (int i = 0; i < 8; i = i + 1) begin
            memory[i] <= 12'd0;
        end
    end else begin
        if (enable == 1'b1) begin
            memory[write_address] <= data_in;
        end
    end
end

always @ (posedge clk) begin
    if (reset == 1'b1) begin
        read_data <= 12'd0;
    end else begin
        if (enable == 1'b1) begin
            read_data <= memory[next_address];
        end
    end
end

always @ (posedge clk) begin
    if (reset == 1'b1) begin
        write_address <= 3'b000;
    end else begin
        if (enable == 1'b1) begin
            write_address <= write_address + 1'b1;
        end
    end
end

always @ (posedge clk) begin
    if (reset == 1'b1) begin
        sum <= 15'd0;
    end else begin
        if (enable == 1'b1) begin
            sum <= sum + data_in - read_data;
        end
    end
end

assign data_out = sum[14 : 3];

endmodule