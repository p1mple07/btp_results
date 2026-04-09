module sync_lifo #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 3) (
    input clk,
    input reset,
    input write_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg empty,
    output reg full,
    output [DATA_WIDTH-1:0] data_out
);

    // Define the memory array with configurable depth
    logic [DATA_WIDTH-1:0] mem [((1<<ADDR_WIDTH)-1:0)];
    logic [ADDR_WIDTH-1:0] head, tail;

    // Initialize the memory and pointers
    initial begin
        empty = 1'b1;
        full = 1'b0;
        head = 0;
        tail = (1<<ADDR_WIDTH)-1;
        mem = {{(1 << DATA_WIDTH)-1{1'b0}}}; // Fill with zeros
    end

    // Process on rising edge of the clock
    always_ff @(posedge clk) begin
        if (reset) begin
            empty <= 1'b1;
            full <= 1'b0;
            mem = {{(1 << DATA_WIDTH)-1{1'b0}}};
            head = 0;
            tail = (1<<ADDR_WIDTH)-1;
        end else begin
            if (write_en && !full) begin
                mem[tail] = data_in;
                tail = (tail + 1) & ((1<<ADDR_WIDTH)-1);
                full <= 1'b0;
            end

            if (read_en && !empty) begin
                data_out <= mem[head];
                head = (head + 1) & ((1<<ADDR_WIDTH)-1);
                empty <= 1'b0;
            end
        end
    end

endmodule
