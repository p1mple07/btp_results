module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
) (
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire read_en,
    input wire [ADDR_WIDTH-1:0] data_in,
    output reg data_out,
    output reg empty,
    output reg full
);

localparam depth = 2**ADDR_WIDTH;
reg [ADDR_WIDTH-1:0] mem[0:depth-1];
reg current_top = 0;
reg write_done = 0;

@(posedge clk) begin
    if (reset) begin
        current_top <= 0;
        mem[0] <= 0;
        full <= 0;
        empty <= 1;
    end else begin
        if (write_en) begin
            if (!full) begin
                mem[current_top] <= data_in;
                current_top = (current_top + 1) mod depth;
                write_done = 1;
            end
        end else if (read_en) begin
            data_out <= mem[current_top];
            empty <= 1;
            full <= 0;
        end
    end
end

assign empty = full;
assign full = ~write_done & full;

endmodule
