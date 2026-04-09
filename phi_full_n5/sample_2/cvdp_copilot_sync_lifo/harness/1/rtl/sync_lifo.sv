module sync_lifo #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 3)
(
    input clk,
    input reset,
    input write_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg empty,
    output reg full,
    output [DATA_WIDTH-1:0] data_out
);

    reg [ADDR_WIDTH-1:0] address;
    reg [DATA_WIDTH-1:0] memory [2**ADDR_WIDTH-1:0];
    integer index;

    always_ff @(posedge clk) begin
        if (reset) begin
            empty <= 1;
            full <= 0;
            address <= 0;
            for (index = 0; index < 2**ADDR_WIDTH; index = index + 1) begin
                memory[index] <= 0;
            end
        end else begin
            if (write_en && !full) begin
                memory[address] <= data_in;
                address <= address + 1;
                if (address == 2**ADDR_WIDTH-1) begin
                    address <= 0;
                    full <= 1;
                end
            end

            if (read_en && !empty) begin
                data_out <= memory[address];
                address <= address - 1;
                if (address == 0) begin
                    empty <= 0;
                    full <= 1;
                end
            end
        end
    end
endmodule
