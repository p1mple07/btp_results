module moving_average(
    input wire clk,
    input wire reset,
    input  wire [11 : 0] data_in,
    output wire [11 : 0] data_out,
    input wire enable
);

reg [11 : 0] memory [7 : 0];
reg [14 : 0] sum;
reg [2 : 0] write_address;
wire [2 : 0] next_address;
reg [11 : 0] read_data;

always @(posedge clk or enable) begin
    if enable
        integer i;
        always @(posedge clk) begin
            if (reset == 1'b1) begin
                for (i = 0; i < 8; i = i + 1) begin
                    memory[i] <= 'h0;
                end
            end
        end
        always @(posedge clk) begin
            if (reset == 1'b1) begin
                read_data <= memory[next_address];
            end
        end
        always @(posedge clk) begin
            if (reset == 1'b1) begin
                write_address <= write_address + 1'b1;
            end
        end
        always @(posedge clk) begin
            if (reset == 1'b1) begin
                sum <= sum + data_in - read_data;
            end
        end
        always @(posedge clk) begin
            if (reset == 1'b1) begin
                data_out <= sum[14:3];
            end
        end
    end
end
