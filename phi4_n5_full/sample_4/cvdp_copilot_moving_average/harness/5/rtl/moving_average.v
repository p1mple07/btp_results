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

    // Write current input to memory only when enable is high.
    integer i;
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            for (i = 0; i < 8; i = i + 1) begin
                memory[i] <= 'h0;
            end
        end else if (enable == 1'b1) begin
            memory[write_address] <= data_in;
        end
    end

    // Read the oldest element from memory only when enable is high.
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            read_data <= 'h0;
        end else if (enable == 1'b1) begin
            read_data <= memory[next_address];
        end
    end

    // Increment the write address only when enable is high.
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            write_address <= 'h0;
        end else if (enable == 1'b1) begin
            write_address <= write_address + 1'b1;
        end
    end

    // Update the sum only when enable is high.
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            sum <= 'h0;
        end else if (enable == 1'b1) begin
            sum <= sum + data_in - read_data;
        end
    end

endmodule