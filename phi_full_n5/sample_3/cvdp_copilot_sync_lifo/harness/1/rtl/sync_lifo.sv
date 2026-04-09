module sync_lifo #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 3)
(
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire read_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg empty,
    output reg full,
    output reg [DATA_WIDTH-1:0] data_out
);

    localparam int DEPTH = 2**ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] head;
    reg [DATA_WIDTH-1:0] tail;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            head <= 0;
            tail <= 0;
            mem <= {{DEPTH{1'b0}}} ;
            empty <= 1;
            full <= 0;
        end else begin
            if (reset) begin
                head <= 0;
                tail <= 0;
                empty <= 1;
                full <= 0;
            end else if (write_en && !full) begin
                mem[tail] <= data_in;
                tail <= tail + 1;
                full <= 0;
            end
            if (read_en && !empty) begin
                data_out <= mem[head];
                head <= head + 1;
                empty <= 0;
                full <= (tail == DEPTH-1);
            end
        end
    end

endmodule
