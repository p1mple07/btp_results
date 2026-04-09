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

    reg [ADDR_WIDTH-1:0] addr_counter;
    reg [DATA_WIDTH-1:0] memory[0:2**ADDR_WIDTH-1];
    integer i;

    // Initialize on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            empty <= 1;
            full <= 0;
            addr_counter <= 0;
            for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
                memory[i] <= 0;
            end
        end else begin
            if (reset) begin
                empty <= 0;
                full <= 0;
            end
        end
    end

    // Write operation
    always @(posedge clk) begin
        if (write_en && !full) begin
            memory[addr_counter] <= data_in;
            addr_counter <= addr_counter + 1;
            full <= 1;
        end
    end

    // Read operation
    always @(posedge clk) begin
        if (read_en && !empty) begin
            data_out <= memory[addr_counter];
            addr_counter <= addr_counter - 1;
            empty <= 0;
        end
    end

endmodule
